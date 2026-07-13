import SwiftUI
import AtlasCore
import AtlasImaging

// Motor de uma conversa: carrega mensagens, envia + STREAMING ao vivo, registra
// feedback governado, e — o diferencial vs Cursor — expõe a EXECUÇÃO agêntica ao
// vivo (a orquestra: quais agentes/providers/modelos, o estágio do Atlas Decide),
// via poll do trace durante o turno.

struct ExecAgent: Equatable, Identifiable {
    let id: String
    let agent: String?     // orquestrador / atlas / …
    let provider: String?  // hermes_cli / claude_cli / …
    let model: String?     // claude-sonnet-4-6 / qwen3.6-27b / …
    let status: String     // queued / processing / succeeded / failed / …
}

struct ChatBubble: Identifiable, Equatable {
    let id: String
    let role: String
    var text: String
    var streaming: Bool = false
    var traceId: String? = nil
    var provider: String? = nil
    var model: String? = nil
    var feedbackAction: String? = nil
    // Execução ao vivo (a orquestra)
    var startedAt: Date? = nil
    var elapsedMs: Int? = nil
    var agents: [ExecAgent] = []
    var decideStage: String? = nil
    var decideStrategy: String? = nil
}

// Anexo local (pré-envio) — o ÚNICO contrato de UI de anexos: a strip do
// composer renderiza isto e nada mais. O AttachmentInput correspondente vive
// no model, fora da View.
struct LocalDraft: Identifiable, Equatable {
    enum State: Equatable { case pronto, subindo, falhou(String) }
    let id: String
    let fileName: String
    let mimeType: String
    let kind: AtlasAttachmentKind
    let bytes: Int
    let preview: Data?     // pequena o bastante pra UIImage(data:) direto
    var state: State = .pronto
}

enum FeedbackKind: String, CaseIterable, Identifiable {
    case util, contexto, longo, fraco
    var id: String { rawValue }
    var label: String {
        switch self {
        case .util: return "útil"; case .contexto: return "contexto"
        case .longo: return "longo"; case .fraco: return "fraco"
        }
    }
    var payload: FeedbackAiInteractionInput {
        switch self {
        case .util: return .init(feedbackScore: 5, feedbackAction: "useful")
        case .contexto: return .init(feedbackScore: 1, feedbackAction: "wrong_context")
        case .longo: return .init(feedbackScore: 2, feedbackComment: "[too_long]")
        case .fraco: return .init(feedbackScore: 1, feedbackComment: "[weak]")
        }
    }
    var activeAction: String {
        switch self {
        case .util: return "useful"; case .contexto: return "wrong_context"
        case .longo: return "too_long"; case .fraco: return "weak"
        }
    }
}

@MainActor
@Observable
final class ConversationModel {
    var bubbles: [ChatBubble] = []
    var isSending = false
    var loadError: String?
    var toast: String?
    // Workspace da conversa — entra no payload do create (workspace_slug/name/path,
    // padrão do mobile RN; o servidor lê payload.workspace_* no AiGateway/AWIS).
    var workspaceName: String?
    var workspaceSlug: String?
    var workspacePath: String?
    // Anexos do próximo envio + progresso agregado do upload (0…1, nil = ocioso)
    var drafts: [LocalDraft] = []
    var uploadPercent: Double?

    private let client: AtlasClient
    private(set) var threadId: String?
    private var poll: Task<Void, Never>?
    private var stream: Task<Void, Never>?
    private var attachmentInputs: [String: AttachmentInput] = [:]
    @ObservationIgnored private let engine: AtlasRichInputEngine

    /// Salt por instalação — escopa o client_upload_id no staging do servidor
    /// (que NÃO separa por device): iPhone e Mac futuro nunca colidem.
    private static let installSalt: String = {
        let key = "atlas.install.salt"
        if let s = UserDefaults.standard.string(forKey: key) { return s }
        let s = UUID().uuidString
        UserDefaults.standard.set(s, forKey: key)
        return s
    }()

    init(client: AtlasClient, threadId: String?) {
        self.client = client
        self.threadId = threadId
        self.engine = AtlasRichInputEngine(transport: client, installSalt: Self.installSalt)
    }

    // MARK: - Anexos (imagem via PhotosPicker/câmera/clipboard)

    func addImage(data: Data, suggestedName: String?, mimeType: String, identity: String) {
        guard drafts.filter({ $0.kind == .image }).count < AtlasAttachmentLimits.canonical.maxImages else {
            toast = "máximo de 8 imagens"; return
        }
        do {
            // AtlasImaging: HEIC→JPEG, resize 2048, EXIF — ANTES do engine.
            let n = try AtlasImaging.normalize(data, mimeType: mimeType)
            let ext = n.mimeType == "image/png" ? "png" : n.mimeType == "image/gif" ? "gif" : "jpg"
            let name = suggestedName ?? "foto-\(Int(Date().timeIntervalSince1970)).\(ext)"
            let id = "att-\(UUID().uuidString.prefix(8))"
            attachmentInputs[id] = AttachmentInput(
                kind: .image, fileName: name, mimeType: n.mimeType, source: "photos",
                identity: identity, bytes: DataByteSource(n.data),
                width: n.width, height: n.height)
            drafts.append(LocalDraft(id: id, fileName: name, mimeType: n.mimeType,
                                     kind: .image, bytes: n.data.count, preview: n.data))
        } catch {
            toast = "imagem inválida: \(error)"
        }
    }

    func removeDraft(_ id: String) {
        drafts.removeAll { $0.id == id }
        attachmentInputs.removeValue(forKey: id)
    }

    func load() async {
        guard let threadId else { return }
        do {
            let response = try await client.getAiThread(threadId)
            if let w = response.thread.workspace, !w.isEmpty {
                workspacePath = w
                workspaceName = (w as NSString).lastPathComponent
                workspaceSlug = workspaceName?.lowercased()
            }
            bubbles = (response.thread.messages ?? [])
                .sorted { $0.position < $1.position }
                .map { ChatBubble(id: $0.id, role: $0.role, text: $0.content,
                                  traceId: $0.traceId, provider: $0.provider, model: $0.model) }
        } catch {
            loadError = String(describing: error)
        }
    }

    func send(_ text: String, effort: AtlasComputeEffort = .auto) async {
        var trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sendingDrafts = drafts
        // Só anexos, sem texto → prompt sintético (paridade com o RN)
        if trimmed.isEmpty && !sendingDrafts.isEmpty {
            trimmed = "analise \(sendingDrafts.count == 1 ? "o anexo enviado" : "os \(sendingDrafts.count) anexos enviados")"
        }
        guard !trimmed.isEmpty, !isSending else { return }
        isSending = true

        bubbles.append(ChatBubble(id: "local-user-\(bubbles.count)", role: "user", text: trimmed))
        let aid = "local-assistant-\(bubbles.count)"
        bubbles.append(ChatBubble(id: aid, role: "assistant", text: "", streaming: true, startedAt: Date()))

        // 1. Upload dos anexos ANTES do create (chunked + resume + sha via engine).
        var fields: RichInputInteractionFields? = nil
        if !sendingDrafts.isEmpty {
            for i in drafts.indices { drafts[i].state = .subindo }
            do {
                let inputs = sendingDrafts.compactMap { attachmentInputs[$0.id] }
                let images = inputs.filter { $0.kind == .image }
                let documents = inputs.filter { $0.kind != .image }
                let uploaded = try await engine.uploadAll(
                    images: images, documents: documents,
                    progress: { [weak self] p in
                        Task { @MainActor [weak self] in
                            self?.uploadPercent = p.phase == .complete ? nil : p.percent
                        }
                    })
                fields = engine.interactionFields(images: uploaded.images,
                                                  documents: uploaded.documents,
                                                  inputText: trimmed)
                drafts.removeAll(); attachmentInputs.removeAll()
                uploadPercent = nil
            } catch {
                for i in drafts.indices { drafts[i].state = .falhou("\(error)") }
                uploadPercent = nil
                update(aid) { $0.text = "⚠️ upload falhou: \(error)"; $0.streaming = false }
                isSending = false
                return
            }
        }

        do {
            // Payload do turno:
            // - tool_permissions.mode=read — menor privilégio; o default do servidor
            //   é `danger`, que trava o chat exigindo workspace-cert.
            // - compute_effort — só quando ≠ auto (auto = Atlas Decide escolhe),
            //   mesmo lane do RN (payload.compute_effort).
            // - workspace_slug/name/path — escopo do repo, padrão do mobile RN.
            //   (O "modo" geral/operacional/… do composer é UI-only: não existe
            //   campo de wire pra ele no chat hoje; não inventamos contrato.)
            var payload: [String: JSONValue] = [
                "tool_permissions": .object(["mode": .string("read")]),
            ]
            if let e = effort.payloadValue { payload["compute_effort"] = .string(e) }
            if let slug = workspaceSlug {
                payload["workspace_slug"] = .string(slug)
                payload["workspace_name"] = .string(workspaceName ?? slug)
                if let p = workspacePath { payload["workspace_path"] = .string(p) }
            }
            let input = CreateAiInteractionInput(inputText: trimmed, threadId: threadId,
                                                 newThread: threadId == nil ? true : nil,
                                                 payload: JSONObject(payload),
                                                 uploadedImages: fields?.uploadedImages.isEmpty == false ? fields?.uploadedImages : nil,
                                                 uploadedDocuments: fields?.uploadedDocuments.isEmpty == false ? fields?.uploadedDocuments : nil,
                                                 richInputPayload: fields?.richInputPayload)
            let created = try await client.createAiInteraction(input)
            if threadId == nil { threadId = created.trace.threadId }
            let traceId = created.trace.id
            update(aid) { $0.traceId = traceId; $0.provider = created.trace.provider }

            // Poll da execução (a orquestra) em paralelo ao stream de conteúdo.
            poll = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_300_000_000)
                    guard let self, !Task.isCancelled else { break }
                    guard let resp = try? await self.client.getAiInteraction(traceId) else { continue }
                    self.applyExecution(aid, resp.trace)
                    if ["succeeded", "failed", "cancelled"].contains(resp.trace.status) { break }
                }
            }

            // Stream numa Task PRÓPRIA (guardada em `stream`) para o Stop cancelar
            // de verdade — cancelar a Task derruba o AsyncThrowingStream (o
            // onTermination do AtlasClient cancela a conexão SSE por baixo).
            let client = self.client
            stream = Task { [weak self] in
                var live = ""
                do {
                    frames: for try await frame in await client.streamInteraction(traceId: traceId) {
                        guard let self, !Task.isCancelled else { break frames }
                        switch frame {
                        case .event(let e): live += e.content; self.update(aid) { $0.text = live; $0.streaming = true }
                        case .done: break frames   // fim do turno — sair do LOOP, não só do switch
                        case .error(let p):
                            let m = p["message"]?.stringValue ?? "erro no stream"
                            self.update(aid) { $0.text = live.isEmpty ? "⚠️ \(m)" : live }
                        case .ignored: break
                        }
                    }
                } catch {
                    self?.update(aid) { if $0.text.isEmpty { $0.text = "⚠️ \(error)" } }
                }
            }
            await stream?.value
            poll?.cancel()
            finalize(aid, traceId: traceId)
        } catch {
            update(aid) { $0.text = "⚠️ \(error)"; $0.streaming = false }
        }
        isSending = false
    }

    func cancel() {
        poll?.cancel(); stream?.cancel()
        // Stop de verdade: não há endpoint de cancel por interaction — a unidade
        // real de execução são os JOBS. Cancela no servidor os ativos deste turno.
        let active = bubbles.last(where: { $0.streaming })?
            .agents.filter { ["queued", "processing"].contains($0.status) } ?? []
        if !active.isEmpty {
            let client = self.client
            Task.detached { for j in active { _ = try? await client.cancelAiJob(j.id) } }
        }
        for i in bubbles.indices where bubbles[i].streaming { bubbles[i].streaming = false }
        isSending = false
        toast = "cancelado"
    }

    func feedback(_ bubbleId: String, _ kind: FeedbackKind) async {
        guard let i = bubbles.firstIndex(where: { $0.id == bubbleId }), let trace = bubbles[i].traceId else { return }
        let previous = bubbles[i].feedbackAction
        bubbles[i].feedbackAction = kind.activeAction
        do {
            _ = try await client.feedbackAiInteraction(trace, feedback: kind.payload)
            toast = "\(kind.label) registrado"
        } catch {
            bubbles[i].feedbackAction = previous
            toast = "feedback falhou"
        }
    }

    // MARK: - Execução

    private func applyExecution(_ id: String, _ trace: AtlasAiTrace) {
        let agents = (trace.jobs ?? []).map {
            ExecAgent(id: $0.id, agent: $0.agentSlug, provider: $0.provider, model: $0.model, status: $0.status)
        }
        update(id) {
            $0.agents = agents
            $0.decideStrategy = trace.atlasDecideExecution?.strategy
            $0.decideStage = trace.atlasDecideExecution?.atlasDecideStage
        }
    }

    private func finalize(_ id: String, traceId: String) {
        Task { [weak self] in
            guard let self else { return }
            let final = try? await self.client.getAiInteraction(traceId)
            self.update(id) {
                $0.streaming = false
                $0.agents = []
                $0.decideStage = nil
                if let t = final?.trace {
                    $0.model = t.model ?? $0.model
                    $0.elapsedMs = t.latencyMs ?? $0.startedAt.map { Int(Date().timeIntervalSince($0) * 1000) }
                }
            }
        }
    }

    private func update(_ id: String, _ mutate: (inout ChatBubble) -> Void) {
        guard let i = bubbles.firstIndex(where: { $0.id == id }) else { return }
        mutate(&bubbles[i])
    }
}
