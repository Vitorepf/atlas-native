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
    var currentActivity: AtlasAgentActivity? { atlasCurrentAgentActivity(from: activities) }
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
    private static let effortPreferenceKey = "atlas.composer.effort"

    private struct PendingAttachmentPreparation {
        let kind: AtlasAttachmentKind
        let task: Task<Void, Never>
    }

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
    /// Follow-ups enviados durante um turno. A casca mostra esta lista como
    /// `Fila N`; a persistência/FIFO vivem no Core, não na View.
    var queuedMessages: [QueuedMessage] = []
    /// Preferência persistente pertence ao model; a View só renderiza/cicla.
    var effort: AtlasComputeEffort

    private let client: AtlasClient
    private(set) var threadId: String?
    private var activeRun: InteractionRun?
    private var attachmentInputs: [String: AttachmentInput] = [:]
    @ObservationIgnored private var pendingAttachmentPreparations: [String: PendingAttachmentPreparation] = [:]
    @ObservationIgnored private let engine: AtlasRichInputEngine
    @ObservationIgnored private let outbox: InteractionOutbox
    @ObservationIgnored private let queueStore: QueuedFollowUpStore
    @ObservationIgnored private var queueScope: String

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
        self.queueStore = QueuedFollowUpStore(fileURL: QueuedFollowUpStore.applicationSupportFileURL())
        self.queueScope = threadId.map { "thread:\($0)" } ?? "local:\(UUID().uuidString.lowercased())"
        self.effort = AtlasComputeEffort(
            rawValue: UserDefaults.standard.string(forKey: Self.effortPreferenceKey) ?? ""
        ) ?? .auto
    }

    func cycleEffort() {
        effort = effort.next
        UserDefaults.standard.set(effort.rawValue, forKey: Self.effortPreferenceKey)
    }

    // MARK: - Anexos (imagem via PhotosPicker/câmera/clipboard)

    func addImage(
        data: Data,
        suggestedName: String?,
        mimeType: String,
        identity: String,
        source: String = "photos"
    ) {
        do {
            try ensureCapacity(for: .image)
        } catch {
            toast = String(describing: error)
            return
        }
        let id = "att-\(UUID().uuidString.prefix(8))"
        let task = Task { @MainActor [weak self] in
            do {
                // Decode, HEIC→JPEG, resize e thumbnail acontecem fora da
                // MainActor. Só a mutação observável volta para o model.
                let prepared = try await AtlasImaging.prepareForComposer(
                    data, mimeType: mimeType
                )
                guard let self else { return }
                self.pendingAttachmentPreparations[id] = nil
                guard !Task.isCancelled else { return }
                let n = prepared.upload
                let ext = n.mimeType == "image/png" ? "png" : n.mimeType == "image/gif" ? "gif" : "jpg"
                let name = suggestedName ?? "foto-\(Int(Date().timeIntervalSince1970)).\(ext)"
                let input = AtlasAttachmentAdapter.data(
                    n.data, fileName: name, mimeType: n.mimeType, source: source,
                    identity: identity, width: n.width, height: n.height
                )
                self.append(input, id: id, preview: prepared.preview.data)
            } catch is CancellationError {
                self?.pendingAttachmentPreparations[id] = nil
            } catch {
                self?.pendingAttachmentPreparations[id] = nil
                self?.toast = "imagem inválida: \(error)"
            }
        }
        pendingAttachmentPreparations[id] = .init(kind: .image, task: task)
    }

    func addFile(url: URL) {
        let fileName = url.lastPathComponent
        let mime = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType
            ?? "application/octet-stream"
        let kind = AtlasAttachmentClassifier.detect(mimeType: mime, fileName: fileName).kind
        do {
            try ensureCapacity(for: kind)
        } catch {
            toast = String(describing: error)
            return
        }

        let id = "att-\(UUID().uuidString.prefix(8))"
        let task = Task { @MainActor [weak self] in
            let preparation = Task.detached(priority: .userInitiated) {
                try Task.checkCancellation()
                return try AtlasAttachmentAdapter.file(
                    url: url,
                    mimeType: mime,
                    identity: url.standardizedFileURL.path
                )
            }
            do {
                let input = try await withTaskCancellationHandler {
                    try await preparation.value
                } onCancel: {
                    preparation.cancel()
                }
                guard let self else { return }
                self.pendingAttachmentPreparations[id] = nil
                guard !Task.isCancelled else { return }
                self.append(input, id: id, preview: nil)
            } catch is CancellationError {
                self?.pendingAttachmentPreparations[id] = nil
            } catch {
                self?.pendingAttachmentPreparations[id] = nil
                self?.toast = "não consegui anexar o arquivo: \(error)"
            }
        }
        pendingAttachmentPreparations[id] = .init(kind: kind, task: task)
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
        try ensureCapacity(for: input.kind)
    }

    private func ensureCapacity(for kind: AtlasAttachmentKind) throws {
        let completed = drafts.filter { sharesCapacityGroup($0.kind, kind) }.count
        let pending = pendingAttachmentPreparations.values.filter {
            sharesCapacityGroup($0.kind, kind)
        }.count
        let maximum: Int
        switch kind {
        case .image: maximum = AtlasAttachmentLimits.canonical.maxImages
        case .pdf: maximum = AtlasAttachmentLimits.canonical.maxPdfs
        case .text, .code: maximum = AtlasAttachmentLimits.canonical.maxTextFiles
        case .url: maximum = AtlasAttachmentLimits.canonical.maxUrls
        }
        guard completed + pending < maximum else {
            throw AttachmentAdapterError.limitReached(maximum)
        }
    }

    private func sharesCapacityGroup(_ lhs: AtlasAttachmentKind, _ rhs: AtlasAttachmentKind) -> Bool {
        switch (lhs, rhs) {
        case (.image, .image), (.pdf, .pdf), (.url, .url): return true
        case (.text, .text), (.text, .code), (.code, .text), (.code, .code): return true
        default: return false
        }
    }

    func removeDraft(_ id: String) {
        drafts.removeAll { $0.id == id }
        attachmentInputs.removeValue(forKey: id)
    }

    func load() async {
        await loadQueuedMessages()
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
                    .map { message in
                        let visible = message.role == "assistant"
                            ? atlasVisibleAssistantText(message.content)
                            : message.content
                        return ChatBubble(id: message.id, role: message.role,
                                      text: visible ?? "A resposta anterior continha saída interna e foi ocultada.",
                                      traceId: message.traceId, provider: message.provider, model: message.model)
                    }
                await loadExecutionHistory()
            } catch {
                loadError = String(describing: error)
            }
        }
        await recoverPendingIfNeeded()
    }

    func send(_ text: String, effort: AtlasComputeEffort = .auto) async {
        _ = await sendTurn(text, effort: effort, drainQueueOnSuccess: true)
    }

    /// Enfileira uma instrução como próximo turno. É deliberadamente assíncrono:
    /// a confirmação visual só acontece depois do JSON atômico do Core.
    func queue(text: String) async {
        do {
            guard let message = try await queueStore.enqueue(text: text, scope: queueScope) else { return }
            queuedMessages.append(message)
            toast = "Adicionada à fila"
        } catch {
            toast = "Não foi possível guardar esta instrução na fila."
        }
    }

    /// “Enviar agora” no Fable/Cursor significa enviar no PRÓXIMO turno. Nunca
    /// cancela a execução ou substitui o stream que está em andamento.
    func promote(id: QueuedMessage.ID) async {
        do {
            try await queueStore.promote(id: id, scope: queueScope)
            queuedMessages = await queueStore.messages(scope: queueScope)
        } catch {
            toast = "Não foi possível reordenar a fila."
        }
    }

    func removeQueued(id: QueuedMessage.ID) async {
        do {
            try await queueStore.remove(id: id, scope: queueScope)
            queuedMessages = await queueStore.messages(scope: queueScope)
        } catch {
            toast = "Não foi possível remover esta instrução."
        }
    }

    @discardableResult
    private func sendTurn(
        _ text: String,
        effort: AtlasComputeEffort,
        drainQueueOnSuccess: Bool
    ) async -> Bool {
        var trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Follow-up de texto durante execução: entra na fila imediatamente e
        // não espera upload/preparação nem tenta competir com o stream atual.
        if isSending || activeRun != nil {
            await queue(text: trimmed)
            return false
        }

        await finishPendingAttachmentPreparations()
        let sendingDrafts = drafts
        // Só anexos, sem texto → prompt sintético (paridade com o RN)
        if trimmed.isEmpty && !sendingDrafts.isEmpty {
            trimmed = "analise \(sendingDrafts.count == 1 ? "o anexo enviado" : "os \(sendingDrafts.count) anexos enviados")"
        }
        guard !trimmed.isEmpty else { return false }

        // C4: input_text do servidor tem teto e não é o lugar de transportar
        // uma obra inteira. O Core externaliza >40k como UM Markdown canônico;
        // a bolha local continua mostrando exatamente o que o operador escreveu.
        let originalText = trimmed
        let existingTextFiles = sendingDrafts.filter { $0.kind == .text || $0.kind == .code }.count
        let longMessage: AtlasPreparedLongMessage
        do {
            longMessage = try AtlasLongMessage.prepare(
                originalText, existingTextFileCount: existingTextFiles
            )
        } catch {
            toast = String(describing: error)
            return false
        }
        trimmed = longMessage.inputText
        isSending = true

        bubbles.append(ChatBubble(id: "local-user-\(bubbles.count)", role: "user", text: originalText))
        let aid = "local-assistant-\(bubbles.count)"
        bubbles.append(ChatBubble(id: aid, role: "assistant", text: "", streaming: true, startedAt: Date()))

        // 1. Upload dos anexos ANTES do create (chunked + resume + sha via engine).
        var fields: RichInputInteractionFields? = nil
        if !sendingDrafts.isEmpty || longMessage.attachment != nil {
            for i in drafts.indices { drafts[i].state = .subindo }
            do {
                var inputs = sendingDrafts.compactMap { attachmentInputs[$0.id] }
                if let attachment = longMessage.attachment { inputs.append(attachment) }
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
                return false
            }
        }

        var completedSuccessfully = false
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
            if let metadata = longMessage.metadata {
                payload["long_message"] = .object(metadata.values)
            }
            if let slug = workspaceSlug {
                payload["workspace_slug"] = .string(slug)
                payload["workspace_name"] = .string(workspaceName ?? slug)
                if let p = workspacePath { payload["workspace_path"] = .string(p) }
            }
            #if DEBUG
            let proofProvider = ProcessInfo.processInfo.environment["ATLAS_DEVICE_PROOF_PROVIDER"]
            #else
            let proofProvider: String? = nil
            #endif
            let input = CreateAiInteractionInput(inputText: trimmed,
                                                 clientId: UUID().uuidString.lowercased(),
                                                 threadId: threadId,
                                                 newThread: threadId == nil ? true : nil,
                                                 agentSlug: proofProvider == nil ? nil : "atlas",
                                                 provider: proofProvider,
                                                 sourceType: "app",
                                                 payload: atlasMobileInteractionPayload(base: JSONObject(payload)),
                                                 uploadedImages: fields?.uploadedImages.isEmpty == false ? fields?.uploadedImages : nil,
                                                 uploadedDocuments: fields?.uploadedDocuments.isEmpty == false ? fields?.uploadedDocuments : nil,
                                                 richInputPayload: fields?.richInputPayload)
            completedSuccessfully = try await execute(input, assistantId: aid)
        } catch {
            apply(error, to: aid)
        }
        activeRun = nil
        isSending = false
        if completedSuccessfully && drainQueueOnSuccess {
            await drainQueuedMessages()
        }
        return completedSuccessfully
    }

    private func finishPendingAttachmentPreparations() async {
        while !pendingAttachmentPreparations.isEmpty {
            let tasks = pendingAttachmentPreparations.values.map(\.task)
            for task in tasks { await task.value }
        }
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

    /// O endpoint de lista é deliberadamente leve e não inclui `stream_events`.
    /// Busca os snapshots completos em paralelo para que cada resposta reabra
    /// com sua timeline registrada, inclusive depois de relaunch.
    private func loadExecutionHistory() async {
        let refs = bubbles.compactMap { bubble -> (String, String)? in
            guard bubble.role == "assistant", let traceId = bubble.traceId else { return nil }
            return (bubble.id, traceId)
        }
        let client = self.client
        var snapshots: [(String, AtlasAiTrace?)] = []
        // Bounded fan-out: restaura todo o histórico sem disparar dezenas de
        // requests simultâneos contra o servidor ao abrir uma thread longa.
        var cursor = refs.startIndex
        while cursor < refs.endIndex {
            let end = refs.index(cursor, offsetBy: 6, limitedBy: refs.endIndex) ?? refs.endIndex
            let batch = refs[cursor..<end]
            let values = await withTaskGroup(of: (String, AtlasAiTrace?).self) { group in
                for (bubbleId, traceId) in batch {
                    group.addTask {
                        let trace = try? await client.getAiInteraction(traceId)
                        return (bubbleId, trace?.trace)
                    }
                }
                var values: [(String, AtlasAiTrace?)] = []
                for await value in group { values.append(value) }
                return values
            }
            snapshots.append(contentsOf: values)
            cursor = end
        }
        for (bubbleId, trace) in snapshots {
            if let trace { applyExecution(bubbleId, trace) }
        }
    }

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
            let fromStream = atlasAgentTimeline(from: trace.streamEvents ?? [])
            let recovered = fromStream + trace.toolActivities
            $0.activities = atlasMergeAgentActivities(existing: $0.activities, incoming: recovered)
        }
    }

    private func complete(_ id: String, trace: AtlasAiTrace?) {
        update(id) {
            $0.streaming = false
            $0.agents = []
            $0.decideStage = nil
            if let trace {
                if $0.text.isEmpty, let response = trace.responseText,
                   let visible = atlasVisibleAssistantText(response) { $0.text = visible }
                if $0.text.isEmpty {
                    $0.text = "A execução terminou, mas a resposta continha saída interna e foi ocultada. Tente novamente."
                }
                $0.model = trace.model ?? $0.model
                $0.elapsedMs = trace.latencyMs ?? $0.startedAt.map { Int(Date().timeIntervalSince($0) * 1000) }
            }
        }
    }

    private func execute(_ input: CreateAiInteractionInput, assistantId: String) async throws -> Bool {
        let run = InteractionRun(transport: client, outbox: outbox)
        activeRun = run
        var live = ""
        var completedSuccessfully = false
        for try await event in await run.start(input: input) {
            switch event {
            case .created(let trace):
                if let canonicalThreadId = trace.threadId, threadId != canonicalThreadId {
                    threadId = canonicalThreadId
                    await adoptQueueScope(threadId: canonicalThreadId)
                }
                update(assistantId) { $0.traceId = trace.id; $0.provider = trace.provider }
                applyExecution(assistantId, trace)
            case .activity(let activity):
                update(assistantId) {
                    $0.activities = atlasMergeAgentActivities(
                        existing: $0.activities,
                        incoming: [activity]
                    )
                }
            case .content(let frame):
                guard atlasShouldRenderAssistantContent(frame),
                      let visible = atlasVisibleAssistantText(frame.content) else { continue }
                live = frame.type == "response" ? visible : live + visible
                update(assistantId) { $0.text = live; $0.streaming = true }
            case .execution(let trace):
                applyExecution(assistantId, trace)
            case .remoteError(let payload):
                let message = payload["message"]?.stringValue ?? "erro no stream"
                update(assistantId) { if $0.text.isEmpty { $0.text = "⚠️ \(message)" } }
            case .completed(let done, let finalTrace):
                complete(assistantId, trace: finalTrace)
                completedSuccessfully = done.status.lowercased() == "succeeded"
            }
        }
        activeRun = nil
        return completedSuccessfully
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
            let completedSuccessfully = try await execute(input, assistantId: aid)
            activeRun = nil
            isSending = false
            if completedSuccessfully { await drainQueuedMessages() }
        } catch {
            apply(error, to: aid)
        }
        activeRun = nil
        isSending = false
    }

    private func loadQueuedMessages() async {
        queuedMessages = await queueStore.messages(scope: queueScope)
    }

    private func adoptQueueScope(threadId: String) async {
        let canonicalScope = "thread:\(threadId)"
        guard canonicalScope != queueScope else { return }
        do {
            try await queueStore.migrate(scope: queueScope, to: canonicalScope)
            queueScope = canonicalScope
            await loadQueuedMessages()
        } catch {
            // Mantém o escopo provisório em memória para não abandonar follow-up
            // algum; a próxima abertura pode tentar a migração de novo.
            toast = "A fila continua segura neste aparelho; a conversa ainda está sincronizando."
        }
    }

    private func drainQueuedMessages() async {
        while !isSending && activeRun == nil {
            let next: QueuedMessage?
            do {
                next = try await queueStore.dequeue(scope: queueScope)
            } catch {
                toast = "Não foi possível preparar a próxima instrução da fila."
                return
            }
            guard let next else { return }
            queuedMessages = await queueStore.messages(scope: queueScope)
            let completedSuccessfully = await sendTurn(
                next.text,
                effort: effort,
                drainQueueOnSuccess: false
            )
            // Uma falha/atenção pede decisão do operador; a fila restante fica
            // intacta e visível, nunca dispara trabalho em cascata às cegas.
            guard completedSuccessfully else { return }
        }
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
