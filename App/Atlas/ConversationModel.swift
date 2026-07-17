import SwiftUI
import UniformTypeIdentifiers
import AtlasCore
import AtlasImaging

@MainActor
@Observable
final class ConversationModel {
    private static let effortPreferenceKey = "atlas.composer.effort"
    private static let draftPrefix = "atlas.conversation.draft."
    private static let visitedPrefix = "atlas.conversation.lastVisit."

    private struct PendingAttachmentPreparation {
        let kind: AtlasAttachmentKind
        let task: Task<Void, Never>
    }

    var bubbles: [ChatBubble] = []
    var isSending = false
    var loadError: String?
    var toast: String?
    var cacheCapturedAt: Date?
    var showingStaleCache = false
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
    /// Rascunho persistido por thread. Conversa nova usa escopo local até o
    /// servidor devolver `threadId`, quando o model migra o texto para a chave
    /// canônica da thread.
    var draftText: String = ""
    /// Marcador calculado ao abrir: primeiro turno posterior à visita anterior.
    var firstNewBubbleId: String?
    var lastVisitAt: Date?
    /// Artefatos, diff e decisões de revisão vivem num domínio dedicado. A
    /// conversa só recebe de volta o trace atualizado para refrescar as bolhas.
    let reviews: ChangeReviewModel
    /// Último recibo de continuidade. A View pode projetá-lo, mas nunca cria
    /// sessão/local history por conta própria para simular o handoff.
    var latestSurfaceHandoff: AtlasAiSurfaceHandoff?
    /// Último recibo de steering da execução. Aceite e rejeição vêm do servidor;
    /// a casca não infere se uma instrução entrou na fila do checkpoint seguro.
    var lastSteerReceipt: AtlasInteractionSteerResponse?

    /// Fatos determinísticos coletados por turno e prefixados à pergunta NO FIO.
    /// A bolha do operador continua sendo o que ele escreveu — mesma lei do
    /// `AtlasLongMessage`: o que se transporta não é o que se mostra.
    ///
    /// É isto que torna o card do Código uma conversa ANCORADA em vez de um
    /// chat que opina: quem lê o git é o determinístico, quem entende é o
    /// agente. `nil` (ausente ou devolvendo nil) = conversa normal, sem muleta.
    @ObservationIgnored var turnFacts: ((String) async -> String?)?

    /// A natureza da tarefa, DECLARADA pela superfície (`payload.task_type`).
    ///
    /// O Atlas Decide precisa saber se é código para escolher o motor, e sem
    /// isto ele adivinha farejando palavra na prosa (`hasProgrammingIntentSignal`
    /// procura "repo", "commit"…). Duas consequências ruins: numa conversa sobre
    /// a vida, citar "commit" viraria tarefa de código; e no card do Código —
    /// que é uma tela inteira sobre um repositório — quem acabava decidindo era
    /// o dossiê de fatos que a própria máquina prefixou. A tela SABE o que ela
    /// é; adivinhar o que já se sabe é o desperdício mais bobo de todos.
    @ObservationIgnored var taskKind: String?

    let client: AtlasClient
    private(set) var threadId: ThreadID?
    /// Visível às extensions `+Queue` / `+Execution` (mesmo módulo).
    var activeRun: InteractionRun?
    private var attachmentInputs: [String: AttachmentInput] = [:]
    @ObservationIgnored private var pendingAttachmentPreparations: [String: PendingAttachmentPreparation] = [:]
    @ObservationIgnored private let engine: AtlasRichInputEngine
    @ObservationIgnored private let outbox: InteractionOutbox
    @ObservationIgnored let queueStore: QueuedFollowUpStore
    @ObservationIgnored let readCache: ThreadReadCache
    @ObservationIgnored var queueScope: String
    @ObservationIgnored var draftScope: String

    /// Identidade da execução atual exposta à ponte ActivityKit, nunca à View.
    /// `nil` até o servidor confirmar o trace continua sendo um estado normal.
    var currentStreamingTraceId: TraceID? {
        bubbles.last(where: { $0.streaming && $0.traceId != nil })?.traceId
    }

    init(
        client: AtlasClient,
        threadId: ThreadID?,
        readCache: ThreadReadCache = ThreadReadCache(fileURL: ThreadReadCache.applicationSupportFileURL())
    ) {
        self.client = client
        self.reviews = ChangeReviewModel(client: client)
        self.threadId = threadId
        self.engine = AtlasRichInputEngine(transport: client, installSalt: AtlasInstallationIdentity.id)
        self.outbox = InteractionOutbox(fileURL: InteractionOutbox.applicationSupportFileURL())
        self.queueStore = QueuedFollowUpStore(fileURL: QueuedFollowUpStore.applicationSupportFileURL())
        self.readCache = readCache
        self.queueScope = threadId.map { "thread:\($0.rawValue)" } ?? "local:\(UUID().uuidString.lowercased())"
        self.draftScope = self.queueScope
        self.effort = AtlasComputeEffort(
            rawValue: UserDefaults.standard.string(forKey: Self.effortPreferenceKey) ?? ""
        ) ?? .auto
        self.draftText = Self.loadDraft(scope: draftScope)
        if let threadId {
            self.lastVisitAt = Self.lastVisitDate(threadId: threadId.rawValue)
        }
        self.reviews.onTraceUpdated = { [weak self] traceId, trace in
            guard let self else { return }
            for bubble in self.bubbles where bubble.traceId == traceId {
                self.applyExecution(bubble.id, trace)
            }
        }
    }

    func cycleEffort() {
        effort = effort.next
        UserDefaults.standard.set(effort.rawValue, forKey: Self.effortPreferenceKey)
    }

    func updateDraft(_ value: String) {
        draftText = value
        Self.saveDraft(value, scope: draftScope)
    }

    func markThreadVisited() {
        guard let threadId else { return }
        Self.markVisited(threadId: threadId.rawValue)
    }

    static func lastVisitDate(threadId: String) -> Date? {
        UserDefaults.standard.object(forKey: visitedPrefix + threadId) as? Date
    }

    static func hasNewerContent(_ thread: AtlasAiThread) -> Bool {
        guard let last = AtlasTime.date(thread.lastMessageAt ?? thread.updatedAt) else { return false }
        guard let visit = lastVisitDate(threadId: thread.id) else { return thread.messageCount > 0 }
        return last > visit
    }

    static func loadDraft(scope: String) -> String {
        UserDefaults.standard.string(forKey: draftPrefix + scope) ?? ""
    }

    static func saveDraft(_ value: String, scope: String) {
        let key = draftPrefix + scope
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            UserDefaults.standard.removeObject(forKey: key)
        } else {
            UserDefaults.standard.set(value, forKey: key)
        }
    }

    private static func markVisited(threadId: String) {
        UserDefaults.standard.set(Date(), forKey: visitedPrefix + threadId)
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
            let hydratedFromCache = await hydrateFromCache(threadId: threadId)
            do {
                let response = try await client.getAiThread(threadId.rawValue)
                applyWorkspace(response.thread.workspace)
                let messages = (response.thread.messages ?? []).sorted { $0.position < $1.position }
                let previousVisit = lastVisitAt
                bubbles = Self.bubbles(from: messages)
                firstNewBubbleId = Self.firstNewBubbleId(in: bubbles, after: previousVisit)
                showingStaleCache = false
                cacheCapturedAt = nil
                loadError = nil
                try? await readCache.save(snapshot: Self.snapshot(
                    threadId: threadId.rawValue,
                    workspacePath: response.thread.workspace,
                    messages: messages
                ))
                await loadExecutionHistory()
            } catch {
                if hydratedFromCache || showingStaleCache {
                    toast = "Sem rede agora — mantendo a última leitura salva."
                } else if bubbles.isEmpty {
                    loadError = atlasUserMessage(for: error)
                }
            }
        }
        await recoverPendingIfNeeded()
    }

    func send(_ text: String, effort: AtlasComputeEffort = .auto) async {
        updateDraft("")
        _ = await sendTurn(text, effort: effort, drainQueueOnSuccess: true)
    }

    @discardableResult
    func sendTurn(
        _ text: String,
        effort: AtlasComputeEffort,
        drainQueueOnSuccess: Bool,
        queuedMessageId: QueuedMessage.ID? = nil
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
            #if DEBUG
            let proofProvider = ProcessInfo.processInfo.environment["ATLAS_DEVICE_PROOF_PROVIDER"]
            #else
            let proofProvider: String? = nil
            #endif
            // Fatos antes da pergunta: quem lê o git é o determinístico, quem
            // entende é o agente. Sem isto o agente opina sobre commits que não
            // existem; com isto ele não tem como inventar. A bolha local não
            // muda — o operador vê a própria frase, não o dossiê.
            var wireText = trimmed
            var operatorText: String?
            if let collectFacts = turnFacts,
               let facts = await collectFacts(originalText),
               !facts.isEmpty {
                wireText = facts + "\n\n" + trimmed
                // Quem sabe o que o operador DIGITOU é esta tela, e ela tem de
                // dizer: sem isto o Atlas aprende "regras do operador" lendo o
                // dossiê que a própria máquina anexou — e grava a prosa dela
                // como se fosse a voz dele. Medido: 8 de 13 sinais de
                // aprendizado eram frases que o operador nunca escreveu.
                operatorText = originalText
            }
            // Payload do turno: read-only por padrão, task_type declarado pela
            // superfície, esforço só quando ≠ auto, workspace real e metadata de
            // long message. A política mobile/Hermes continua aplicada abaixo.
            let workspace = workspaceSlug.map {
                TurnPayloadBuilder.Workspace(slug: $0, name: workspaceName, path: workspacePath)
            }
            let payload = TurnPayloadBuilder.build(
                taskKind: taskKind,
                effort: effort,
                workspace: workspace,
                longMessage: longMessage.metadata,
                operatorText: operatorText
            )
            let input = CreateAiInteractionInput(inputText: wireText,
                                                 clientId: UUID().uuidString.lowercased(),
                                                 threadId: threadId?.rawValue,
                                                 newThread: threadId == nil ? true : nil,
                                                 agentSlug: proofProvider == nil ? nil : "atlas",
                                                 provider: proofProvider,
                                                 sourceType: "app",
                                                 payload: atlasMobileInteractionPayload(base: payload),
                                                 uploadedImages: fields?.uploadedImages.isEmpty == false ? fields?.uploadedImages : nil,
                                                 uploadedDocuments: fields?.uploadedDocuments.isEmpty == false ? fields?.uploadedDocuments : nil,
                                                 richInputPayload: fields?.richInputPayload)
            completedSuccessfully = try await execute(
                input,
                assistantId: aid,
                queuedMessageId: queuedMessageId
            )
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
        let activeTraces = bubbles.compactMap { bubble -> (id: String, traceId: TraceID)? in
            guard bubble.streaming, let traceId = bubble.traceId else { return nil }
            return (bubble.id, traceId)
        }
        for i in bubbles.indices where bubbles[i].streaming { bubbles[i].streaming = false }
        isSending = false
        toast = "encerrando sessão…"
        Task {
            await run?.cancel()

            var confirmed = false
            for activeTrace in activeTraces {
                guard let refreshed = try? await client.getAiInteraction(activeTrace.traceId) else { continue }
                applyExecution(activeTrace.id, refreshed.trace)
                confirmed = confirmed || refreshed.trace.turnStatus == .cancelled
            }

            toast = confirmed ? "sessão encerrada" : "cancelamento solicitado"
        }
    }

    func feedback(_ bubbleId: String, _ kind: FeedbackKind) async {
        guard let i = bubbles.firstIndex(where: { $0.id == bubbleId }), let trace = bubbles[i].traceId else { return }
        let previous = bubbles[i].feedbackAction
        bubbles[i].feedbackAction = kind.activeAction
        do {
            _ = try await client.feedbackAiInteraction(trace.rawValue, feedback: kind.payload)
            toast = "\(kind.label) registrado"
        } catch {
            bubbles[i].feedbackAction = previous
            toast = "feedback falhou"
        }
    }

    private func execute(
        _ input: CreateAiInteractionInput,
        assistantId: String,
        queuedMessageId: QueuedMessage.ID? = nil
    ) async throws -> Bool {
        let run = InteractionRun(transport: client, outbox: outbox)
        activeRun = run
        var live = ""
        var completedSuccessfully = false
        for try await event in await run.start(input: input, followUpId: queuedMessageId) {
            switch event {
            case .persisted(let followUpId):
                if let followUpId {
                    await consumeQueuedMessageAfterPersistence(id: followUpId)
                }
            case .created(let trace):
                if let canonicalThreadId = trace.threadId.map({ ThreadID($0) }), threadId != canonicalThreadId {
                    threadId = canonicalThreadId
                    await adoptQueueScope(threadId: canonicalThreadId)
                }
                update(assistantId) { $0.traceId = TraceID(trace.id); $0.provider = trace.provider }
                applyExecution(assistantId, trace)
                Task { await AtlasSession.rhythm.recordActivity(workspace: workspaceName ?? workspaceSlug) }
            case .activity(let activity):
                update(assistantId) {
                    $0.reconnectNotice = nil
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
            case .execution(let snapshot):
                applyExecution(
                    assistantId,
                    snapshot.trace,
                    projectedStreamActivities: snapshot.projectedActivities
                )
            case .reconnecting(let lastSequence, let attempt):
                update(assistantId) {
                    $0.reconnectNotice = "Reconectando ao stream · tentativa \(attempt) · após evento \(lastSequence)"
                }
            case .suspended(let trace):
                complete(assistantId, trace: trace)
                AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
            case .remoteError(let payload):
                let message = payload["message"]?.stringValue ?? "erro no stream"
                update(assistantId) { if $0.text.isEmpty { $0.text = "⚠️ \(message)" } }
            case .completed(let done, let finalTrace):
                complete(assistantId, trace: finalTrace)
                completedSuccessfully = done.turnStatus == .succeeded
                AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
            }
        }
        activeRun = nil
        return completedSuccessfully
    }

    private func recoverPendingIfNeeded() async {
        guard activeRun == nil, !isSending else { return }
        let pending = await outbox.pending()
        guard let input = pending.first(where: {
            if let threadId { return $0.threadId == threadId.rawValue }
            return $0.threadId == nil
        }) else { return }

        // Se o relaunch carregou uma thread já finalizada, não duplica a bolha.
        if let clientId = input.clientId,
           let trace = try? await client.findInteraction(clientId: ClientID(clientId)),
           trace.trace.turnStatus.isTerminal,
           bubbles.contains(where: { $0.traceId == TraceID(trace.trace.id) }) {
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
            let queuedMessageId: String?
            if let clientId = input.clientId {
                queuedMessageId = await outbox.followUpId(clientId: clientId)
            } else {
                queuedMessageId = nil
            }
            let completedSuccessfully = try await execute(
                input,
                assistantId: aid,
                queuedMessageId: queuedMessageId
            )
            activeRun = nil
            isSending = false
            if completedSuccessfully { await drainQueuedMessages() }
        } catch {
            apply(error, to: aid)
        }
        activeRun = nil
        isSending = false
    }

    private func apply(_ error: Error, to id: String) {
        update(id) {
            if $0.text.isEmpty { $0.text = "⚠️ \(atlasUserMessage(for: error))" }
            $0.streaming = false
        }
        toast = atlasUserMessage(for: error)
    }

    func update(_ id: String, _ mutate: (inout ChatBubble) -> Void) {
        guard let i = bubbles.firstIndex(where: { $0.id == id }) else { return }
        mutate(&bubbles[i])
    }

}
