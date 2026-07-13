import SwiftUI
import UniformTypeIdentifiers
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
    var activities: [AtlasAgentActivity] = []
    var currentActivity: AtlasAgentActivity? { activities.last }
    var decisionSummary: AtlasDecisionSummary? = nil
    var qualitySummary: AtlasQualitySummary? = nil
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
    private var activeRun: InteractionRun?
    private var attachmentInputs: [String: AttachmentInput] = [:]
    @ObservationIgnored private let engine: AtlasRichInputEngine
    @ObservationIgnored private let outbox: InteractionOutbox

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
        self.outbox = InteractionOutbox(fileURL: InteractionOutbox.applicationSupportFileURL())
    }

    // MARK: - Anexos (imagem via PhotosPicker/câmera/clipboard)

    func addImage(
        data: Data,
        suggestedName: String?,
        mimeType: String,
        identity: String,
        source: String = "photos"
    ) {
        guard drafts.filter({ $0.kind == .image }).count < AtlasAttachmentLimits.canonical.maxImages else {
            toast = "máximo de 8 imagens"; return
        }
        do {
            // AtlasImaging: HEIC→JPEG, resize 2048, EXIF — ANTES do engine.
            let n = try AtlasImaging.normalize(data, mimeType: mimeType)
            let ext = n.mimeType == "image/png" ? "png" : n.mimeType == "image/gif" ? "gif" : "jpg"
            let name = suggestedName ?? "foto-\(Int(Date().timeIntervalSince1970)).\(ext)"
            let id = "att-\(UUID().uuidString.prefix(8))"
            let input = AtlasAttachmentAdapter.data(
                n.data, fileName: name, mimeType: n.mimeType, source: source,
                identity: identity, width: n.width, height: n.height
            )
            append(input, id: id, preview: n.data)
        } catch {
            toast = "imagem inválida: \(error)"
        }
    }

    func addFile(url: URL) {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let mime = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType
                ?? "application/octet-stream"
            let input = AtlasAttachmentAdapter.data(
                data, fileName: url.lastPathComponent, mimeType: mime,
                source: "files", identity: url.standardizedFileURL.path
            )
            try ensureCapacity(for: input)
            append(input, id: "att-\(UUID().uuidString.prefix(8))", preview: nil)
        } catch {
            toast = "não consegui anexar o arquivo: \(error)"
        }
    }

    func addClipboard(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { toast = "clipboard sem texto"; return }
        do {
            let input = AtlasAttachmentAdapter.clipboard(text: trimmed)
            try ensureCapacity(for: input)
            append(input, id: "att-\(UUID().uuidString.prefix(8))", preview: nil)
        } catch {
            toast = "não consegui anexar o clipboard: \(error)"
        }
    }

    private func append(_ input: AttachmentInput, id: String, preview: Data?) {
        attachmentInputs[id] = input
        drafts.append(LocalDraft(
            id: id, fileName: input.fileName, mimeType: input.mimeType,
            kind: input.kind, bytes: input.bytes.totalBytes, preview: preview
        ))
    }

    private func ensureCapacity(for input: AttachmentInput) throws {
        let count = drafts.filter { draft in
            if input.kind == .image { return draft.kind == .image }
            if input.kind == .pdf { return draft.kind == .pdf }
            return draft.kind == .text || draft.kind == .code
        }.count
        let maximum: Int
        switch input.kind {
        case .image: maximum = AtlasAttachmentLimits.canonical.maxImages
        case .pdf: maximum = AtlasAttachmentLimits.canonical.maxPdfs
        case .text, .code: maximum = AtlasAttachmentLimits.canonical.maxTextFiles
        case .url: maximum = AtlasAttachmentLimits.canonical.maxUrls
        }
        guard count < maximum else {
            throw AttachmentAdapterError.limitReached(maximum)
        }
    }

    func removeDraft(_ id: String) {
        drafts.removeAll { $0.id == id }
        attachmentInputs.removeValue(forKey: id)
    }

    func load() async {
        if let threadId {
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
        await recoverPendingIfNeeded()
    }

    func send(_ text: String, effort: AtlasComputeEffort = .auto) async {
        var trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sendingDrafts = drafts
        // Só anexos, sem texto → prompt sintético (paridade com o RN)
        if trimmed.isEmpty && !sendingDrafts.isEmpty {
            trimmed = "analise \(sendingDrafts.count == 1 ? "o anexo enviado" : "os \(sendingDrafts.count) anexos enviados")"
        }
        guard !trimmed.isEmpty, !isSending, activeRun == nil else { return }
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
            let input = CreateAiInteractionInput(inputText: trimmed,
                                                 clientId: UUID().uuidString.lowercased(),
                                                 threadId: threadId,
                                                 newThread: threadId == nil ? true : nil,
                                                 payload: JSONObject(payload),
                                                 uploadedImages: fields?.uploadedImages.isEmpty == false ? fields?.uploadedImages : nil,
                                                 uploadedDocuments: fields?.uploadedDocuments.isEmpty == false ? fields?.uploadedDocuments : nil,
                                                 richInputPayload: fields?.richInputPayload)
            try await execute(input, assistantId: aid)
        } catch {
            apply(error, to: aid)
        }
        activeRun = nil
        isSending = false
    }

    func cancel() {
        let run = activeRun
        Task { await run?.cancel() }
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
            $0.decisionSummary = trace.decisionSummary
            $0.qualitySummary = trace.qualitySummary
            let known = Set($0.activities.map(\.id))
            $0.activities.append(contentsOf: trace.toolActivities.filter { !known.contains($0.id) })
            if $0.activities.count > 60 { $0.activities.removeFirst($0.activities.count - 60) }
        }
    }

    private func complete(_ id: String, trace: AtlasAiTrace?) {
        update(id) {
            $0.streaming = false
            $0.agents = []
            $0.decideStage = nil
            if let trace {
                if $0.text.isEmpty, let response = trace.responseText { $0.text = response }
                $0.model = trace.model ?? $0.model
                $0.elapsedMs = trace.latencyMs ?? $0.startedAt.map { Int(Date().timeIntervalSince($0) * 1000) }
            }
        }
    }

    private func execute(_ input: CreateAiInteractionInput, assistantId: String) async throws {
        let run = InteractionRun(transport: client, outbox: outbox)
        activeRun = run
        var live = ""
        for try await event in await run.start(input: input) {
            switch event {
            case .created(let trace):
                if threadId == nil { threadId = trace.threadId }
                update(assistantId) { $0.traceId = trace.id; $0.provider = trace.provider }
                applyExecution(assistantId, trace)
            case .activity(let activity):
                update(assistantId) {
                    guard $0.activities.last?.title != activity.title ||
                          $0.activities.last?.detail != activity.detail else { return }
                    $0.activities.append(activity)
                    if $0.activities.count > 60 { $0.activities.removeFirst($0.activities.count - 60) }
                }
            case .content(let frame):
                guard frame.channel == nil || frame.channel == "assistant" else { continue }
                guard frame.type == "token" || frame.type == "response" else { continue }
                guard !frame.content.isEmpty else { continue }
                live = frame.type == "response" ? frame.content : live + frame.content
                update(assistantId) { $0.text = live; $0.streaming = true }
            case .execution(let trace):
                applyExecution(assistantId, trace)
            case .remoteError(let payload):
                let message = payload["message"]?.stringValue ?? "erro no stream"
                update(assistantId) { if $0.text.isEmpty { $0.text = "⚠️ \(message)" } }
            case .completed(_, let finalTrace):
                complete(assistantId, trace: finalTrace)
            }
        }
        activeRun = nil
    }

    private func recoverPendingIfNeeded() async {
        guard activeRun == nil, !isSending else { return }
        let pending = await outbox.pending()
        guard let input = pending.first(where: {
            if let threadId { return $0.threadId == threadId }
            return $0.threadId == nil
        }) else { return }

        // Se o relaunch carregou uma thread já finalizada, não duplica a bolha.
        if let clientId = input.clientId,
           let trace = try? await client.findInteraction(clientId: clientId),
           ["succeeded", "failed", "cancelled"].contains(trace.trace.status),
           bubbles.contains(where: { $0.traceId == trace.trace.id }) {
            try? await outbox.remove(clientId: clientId)
            return
        }

        if !bubbles.suffix(2).contains(where: { $0.role == "user" && $0.text == input.inputText }) {
            bubbles.append(ChatBubble(id: "recovered-user-\(input.clientId ?? UUID().uuidString)",
                                      role: "user", text: input.inputText))
        }
        let aid = "recovered-assistant-\(input.clientId ?? UUID().uuidString)"
        bubbles.append(ChatBubble(id: aid, role: "assistant", text: "", streaming: true, startedAt: Date()))
        isSending = true
        do {
            try await execute(input, assistantId: aid)
        } catch {
            apply(error, to: aid)
        }
        activeRun = nil
        isSending = false
    }

    private func apply(_ error: Error, to id: String) {
        update(id) {
            if $0.text.isEmpty { $0.text = "⚠️ \(Self.userMessage(for: error))" }
            $0.streaming = false
        }
        toast = Self.userMessage(for: error)
    }

    private func update(_ id: String, _ mutate: (inout ChatBubble) -> Void) {
        guard let i = bubbles.firstIndex(where: { $0.id == id }) else { return }
        mutate(&bubbles[i])
    }

    private static func userMessage(for error: Error) -> String {
        if error is AtlasInteractionStreamError {
            return "A conexão com a execução caiu. O Atlas retomará este turno automaticamente."
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost,
                 .cannotFindHost, .timedOut:
                return "A conexão caiu. O Atlas vai recuperar este turno quando a rede voltar."
            default:
                return "Não foi possível falar com o Atlas agora. Tente novamente."
            }
        }
        if let api = error as? AtlasApiError {
            switch api.status {
            case 401, 403: return "A sessão do Atlas precisa ser reconectada."
            case 408, 429: return "O Atlas está ocupado. Este turno continua recuperável."
            case 500...599: return "O servidor Atlas está temporariamente indisponível."
            default: return api.message
            }
        }
        return "A execução foi interrompida. Tente novamente."
    }
}
