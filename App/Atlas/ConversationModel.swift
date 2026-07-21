import AtlasCore
import AtlasImaging
import Foundation
import SwiftUI
import UniformTypeIdentifiers

// IDLE-COMPRESS ConversationModel fused host

@MainActor
extension ConversationModel {
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
}

@MainActor
extension ConversationModel {
    struct PendingAttachmentPreparation {
        let kind: AtlasAttachmentKind
        let task: Task<Void, Never>
    }

    func removeDraft(_ id: String) {
        drafts.removeAll { $0.id == id }
        attachmentInputs.removeValue(forKey: id)
    }

    func finishPendingAttachmentPreparations() async {
        while !pendingAttachmentPreparations.isEmpty {
            let tasks = pendingAttachmentPreparations.values.map(\.task)
            for task in tasks { await task.value }
        }
    }

    func append(_ input: AttachmentInput, id: String, preview: Data?) {
        attachmentInputs[id] = input
        drafts.append(LocalDraft(
            id: id, fileName: input.fileName, mimeType: input.mimeType,
            kind: input.kind, bytes: input.bytes.totalBytes, preview: preview
        ))
    }

    func ensureCapacity(for input: AttachmentInput) throws {
        try ensureCapacity(for: input.kind)
    }

    func ensureCapacity(for kind: AtlasAttachmentKind) throws {
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

    func sharesCapacityGroup(_ lhs: AtlasAttachmentKind, _ rhs: AtlasAttachmentKind) -> Bool {
        switch (lhs, rhs) {
        case (.image, .image), (.pdf, .pdf), (.url, .url): return true
        case (.text, .text), (.text, .code), (.code, .text), (.code, .code): return true
        default: return false
        }
    }
}

@MainActor
extension ConversationModel {
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
}

@MainActor
extension ConversationModel {
    func handoffToSurface(_ destination: AtlasAiSurfaceDestination) async {
        guard let threadId else {
            toast = "A conversa ainda não possui uma sessão canônica para continuar."
            return
        }

        do {
            latestSurfaceHandoff = try await client.handoffAiThreadSurface(
                threadId.rawValue,
                input: .init(toSurface: destination)
            ).handoff
        } catch {
            toast = "Não foi possível preparar a continuidade: \(error)"
        }
    }

    func registerLiveActivityPushToken(
        traceId: TraceID,
        activityId: String,
        pushToken: String,
        environment: AtlasLiveActivityRegistrationInput.Environment,
        startedAt: Date,
        frequentUpdatesEnabled: Bool
    ) async -> AtlasLiveActivityRegistrationReceipt? {
        do {
            return try await client.registerLiveActivity(.init(
                traceId: traceId.rawValue,
                activityId: activityId,
                installationId: AtlasInstallationIdentity.id,
                pushToken: pushToken,
                environment: environment,
                startedAt: startedAt,
                frequentUpdatesEnabled: frequentUpdatesEnabled
            ))
        } catch {
            return nil
        }
    }

    func invalidateLiveActivityPushToken(
        traceId: TraceID,
        activityId: String,
        reason: String
    ) async {
        _ = try? await client.invalidateLiveActivity(
            activityId: activityId,
            input: .init(traceId: traceId.rawValue, reason: reason)
        ) as AtlasLiveActivityRegistrationReceipt
    }
}

extension ConversationModel {
    func cycleEffort() {
        setEffort(effort.next)
    }

    func setEffort(_ newEffort: AtlasComputeEffort) {
        effort = newEffort
        UserDefaults.standard.set(newEffort.rawValue, forKey: Self.effortPreferenceKey)
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
        guard last > Date().addingTimeInterval(-7 * 86_400) else { return false }
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

    static func markVisited(threadId: String) {
        UserDefaults.standard.set(Date(), forKey: visitedPrefix + threadId)
    }
}

@MainActor
extension ConversationModel {
    func adoptDraftScope(_ canonicalScope: String) {
        guard canonicalScope != draftScope else { return }
        let current = draftText
        Self.saveDraft("", scope: draftScope)
        draftScope = canonicalScope
        if current.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draftText = Self.loadDraft(scope: canonicalScope)
        } else {
            Self.saveDraft(current, scope: canonicalScope)
        }
        if let threadId { lastVisitAt = Self.lastVisitDate(threadId: threadId.rawValue) }
    }
}

@MainActor
extension ConversationModel {
    func execute(
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

    func apply(_ error: Error, to id: String) {
        update(id) {
            if $0.text.isEmpty { $0.text = "⚠️ \(atlasUserMessage(for: error))" }
            $0.streaming = false
        }
        toast = atlasUserMessage(for: error)
    }
}

@MainActor
extension ConversationModel {
    var currentExecutionPresence: AtlasExecutionPresence? {
        currentPresenceBubble?.executionPresence
    }

    var currentExecutionPresenceTraceId: TraceID? {
        currentPresenceBubble?.traceId
    }

    private var currentPresenceBubble: ChatBubble? {
        bubbles.reversed().first { bubble in
            bubble.traceId != nil && bubble.executionPresence?.isOngoing == true
        }
    }

    func resolveExecutionChoice(jobId: JobID, optionId: String) async {
        do {
            let receipt = try await client.resumeAiJobChoice(jobId.rawValue, optionId: optionId)
            guard let traceId = receipt.job.traceId else {
                toast = "A decisão foi registrada, mas a conversa ainda não está disponível."
                return
            }
            let typedTraceId = TraceID(traceId)
            let refreshed = try await client.getAiInteraction(typedTraceId)
            for bubble in bubbles where bubble.traceId == typedTraceId {
                applyExecution(bubble.id, refreshed.trace)
            }
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }

    func retryTurn(jobId: JobID) async {
        do {
            let receipt = try await client.retryAiJob(jobId.rawValue)
            guard let traceId = receipt.job.traceId else {
                toast = "O turno foi reenfileirado."
                return
            }
            let typedTraceId = TraceID(traceId)
            let refreshed = try await client.getAiInteraction(typedTraceId)
            for bubble in bubbles where bubble.traceId == typedTraceId {
                applyExecution(bubble.id, refreshed.trace)
            }
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }

    func complete(_ id: String, trace: AtlasAiTrace?) {
        update(id) {
            $0.streaming = false
            $0.agents = []
            $0.decideStage = nil
            $0.reconnectNotice = nil
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
}

@MainActor
extension ConversationModel {
    func loadExecutionHistory() async {
        let refs = bubbles.compactMap { bubble -> (String, TraceID)? in
            guard bubble.role == "assistant", let traceId = bubble.traceId else { return nil }
            return (bubble.id, traceId)
        }
        let client = self.client
        var snapshots: [(String, AtlasAiTrace?)] = []
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

    func applyExecution(
        _ id: String,
        _ trace: AtlasAiTrace,
        projectedStreamActivities: [AtlasAgentActivity]? = nil
    ) {
        let agents = (trace.jobs ?? []).map {
            ExecAgent(id: $0.id, agent: $0.agentSlug, provider: $0.provider, model: $0.model, status: $0.status)
        }
        let choiceJob = trace.jobs?.first { $0.turnStatus == .awaitingUserChoice }
        let failedJob = trace.jobs?.first { $0.turnStatus == .failed }
        update(id) {
            $0.agents = agents
            $0.decideStrategy = trace.atlasDecideExecution?.strategy
            $0.decideStage = trace.atlasDecideExecution?.atlasDecideStage
            $0.decisionSummary = trace.decisionSummary
            $0.qualitySummary = trace.qualitySummary
            $0.executionPlan = trace.executionPlan
            $0.diffStats = AtlasTraceGovernance.diffStats(from: trace.metadata)
            $0.planRevisions = AtlasTraceGovernance.planRevisions(from: trace.metadata)
            $0.executionProgress = trace.executionProgress
            $0.executionPresentationState = trace.executionPresentationState
            $0.executionChoiceJobId = choiceJob.map { JobID($0.id) }
            $0.retryableJobId = failedJob.map { JobID($0.id) }
            $0.reconnectNotice = nil
            let fromStream = projectedStreamActivities ?? atlasAgentTimeline(from: trace.streamEvents ?? [])
            let recovered = fromStream + trace.toolActivities
            $0.activities = atlasMergeAgentActivities(existing: $0.activities, incoming: recovered)
        }
    }
}

extension ConversationModel {
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
                loadFailureKind = nil
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
                    loadFailureKind = atlasNetworkFailureKind(for: error)
                }
            }
        }
        await recoverPendingIfNeeded()
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
}

@MainActor
extension ConversationModel {
    func queue(text: String) async {
        do {
            guard let message = try await queueStore.enqueue(text: text, scope: queueScope) else { return }
            queuedMessages.append(message)
            AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
            toast = "Adicionada à fila"
        } catch {
            toast = "Não foi possível guardar esta instrução na fila."
        }
    }

    func promote(id: QueuedMessage.ID) async {
        do {
            try await queueStore.promote(id: id, scope: queueScope)
            queuedMessages = await queueStore.messages(scope: queueScope)
            AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
        } catch {
            toast = "Não foi possível reordenar a fila."
        }
    }

    func removeQueued(id: QueuedMessage.ID) async {
        do {
            try await queueStore.remove(id: id, scope: queueScope)
            queuedMessages = await queueStore.messages(scope: queueScope)
            AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
        } catch {
            toast = "Não foi possível remover esta instrução."
        }
    }

    func loadQueuedMessages() async {
        queuedMessages = await queueStore.messages(scope: queueScope)
        AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
    }

    func adoptQueueScope(threadId: ThreadID) async {
        let canonicalScope = "thread:\(threadId.rawValue)"
        adoptDraftScope(canonicalScope)
        guard canonicalScope != queueScope else { return }
        do {
            try await queueStore.migrate(scope: queueScope, to: canonicalScope)
            queueScope = canonicalScope
            await loadQueuedMessages()
        } catch {
            toast = "A fila continua segura neste aparelho; a conversa ainda está sincronizando."
        }
    }

    func drainQueuedMessages() async {
        while !isSending && activeRun == nil {
            let next = await queueStore.peek(scope: queueScope)
            guard let next else { return }
            let completedSuccessfully = await sendTurn(
                next.text,
                effort: effort,
                drainQueueOnSuccess: false,
                queuedMessageId: next.id
            )
            guard completedSuccessfully else { return }
        }
    }

    func consumeQueuedMessageAfterPersistence(id: QueuedMessage.ID) async {
        do {
            try await queueStore.remove(id: id, scope: queueScope)
            queuedMessages = await queueStore.messages(scope: queueScope)
            AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
        } catch {
            toast = "A próxima instrução continua guardada e será reconciliada."
        }
    }
}

extension ConversationModel {
    func hydrateFromCache(threadId: ThreadID) async -> Bool {
        guard let snapshot = await readCache.load(threadId: threadId.rawValue) else {
            showingStaleCache = false
            cacheCapturedAt = nil
            return false
        }
        applyWorkspace(snapshot.workspacePath)
        bubbles = Self.bubbles(from: snapshot.messages)
        cacheCapturedAt = snapshot.capturedAt
        showingStaleCache = true
        loadError = nil
        loadFailureKind = nil
        return true
    }

    func applyWorkspace(_ path: String?) {
        guard let path, !path.isEmpty else { return }
        workspacePath = path
        workspaceName = (path as NSString).lastPathComponent
        workspaceSlug = workspaceName?.lowercased()
    }
}

extension ConversationModel {
    static func bubbles(from messages: [AtlasAiMessage]) -> [ChatBubble] {
        messages.map { message in
            bubble(
                id: message.id,
                role: message.role,
                content: message.content,
                traceId: message.traceId,
                provider: message.provider,
                model: message.model,
                occurredAt: message.occurredAt
            )
        }
    }

    static func bubbles(from messages: [ThreadReadCache.Message]) -> [ChatBubble] {
        messages.map { message in
            bubble(
                id: message.id,
                role: message.role,
                content: message.content,
                traceId: message.traceId,
                provider: message.provider,
                model: message.model,
                occurredAt: message.occurredAt
            )
        }
    }

    static func bubble(
        id: String,
        role: String,
        content: String,
        traceId: String?,
        provider: String?,
        model: String?,
        occurredAt: String? = nil
    ) -> ChatBubble {
        let visible = role == "assistant"
            ? atlasVisibleAssistantText(content)
            : content
        return ChatBubble(
            id: id,
            role: role,
            text: visible ?? "A resposta anterior continha saída interna e foi ocultada.",
            traceId: traceId.map { TraceID($0) },
            occurredAt: occurredAt,
            provider: provider,
            model: model
        )
    }

    static func firstNewBubbleId(in bubbles: [ChatBubble], after visit: Date?) -> String? {
        guard let visit else { return nil }
        return bubbles.first { bubble in
            guard let occurred = AtlasTime.date(bubble.occurredAt) else { return false }
            return occurred > visit
        }?.id
    }

    static func snapshot(
        threadId: String,
        workspacePath: String?,
        messages: [AtlasAiMessage]
    ) -> ThreadReadCache.Snapshot {
        ThreadReadCache.Snapshot(
            threadId: threadId,
            capturedAt: Date(),
            workspacePath: workspacePath,
            messages: messages.map {
                ThreadReadCache.Message(
                    id: $0.id,
                    role: $0.role,
                    content: $0.content,
                    traceId: $0.traceId,
                    provider: $0.provider,
                    model: $0.model,
                    occurredAt: $0.occurredAt
                )
            }
        )
    }
}

@MainActor
extension ConversationModel {
    func recoverPendingIfNeeded() async {
        guard activeRun == nil, !isSending else { return }
        let pending = await outbox.pending()
        guard let input = pending.first(where: {
            if let threadId { return $0.threadId == threadId.rawValue }
            return $0.threadId == nil
        }) else { return }

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
}

@MainActor
extension ConversationModel {
    @discardableResult
    func sendTurn(
        _ text: String,
        effort: AtlasComputeEffort,
        drainQueueOnSuccess: Bool,
        queuedMessageId: QueuedMessage.ID? = nil
    ) async -> Bool {
        var trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if isSending || activeRun != nil {
            await queue(text: trimmed)
            return false
        }

        await finishPendingAttachmentPreparations()
        let sendingDrafts = drafts
        if trimmed.isEmpty && !sendingDrafts.isEmpty {
            trimmed = "analise \(sendingDrafts.count == 1 ? "o anexo enviado" : "os \(sendingDrafts.count) anexos enviados")"
        }
        guard !trimmed.isEmpty else { return false }

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

        var fields: RichInputInteractionFields? = nil
        if !sendingDrafts.isEmpty || longMessage.attachment != nil {
            guard let uploaded = await uploadForSendTurn(
                sendingDrafts: sendingDrafts,
                longMessage: longMessage,
                trimmed: trimmed,
                assistantId: aid
            ) else { return false }
            fields = uploaded
        }

        var completedSuccessfully = false
        do {
            let input = await buildSendTurnInput(
                originalText: originalText,
                trimmed: trimmed,
                effort: effort,
                longMessage: longMessage,
                fields: fields
            )
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

    var currentStreamingTraceId: TraceID? {
        bubbles.last(where: { $0.streaming && $0.traceId != nil })?.traceId
    }

    func send(_ text: String, effort: AtlasComputeEffort = .auto) async {
        updateDraft("")
        _ = await sendTurn(text, effort: effort, drainQueueOnSuccess: true)
    }

    func update(_ id: String, _ mutate: (inout ChatBubble) -> Void) {
        guard let i = bubbles.firstIndex(where: { $0.id == id }) else { return }
        mutate(&bubbles[i])
    }
}

@MainActor
extension ConversationModel {
    func buildSendTurnInput(
        originalText: String,
        trimmed: String,
        effort: AtlasComputeEffort,
        longMessage: AtlasPreparedLongMessage,
        fields: RichInputInteractionFields?
    ) async -> CreateAiInteractionInput {
        #if DEBUG
        let proofProvider = ProcessInfo.processInfo.environment["ATLAS_DEVICE_PROOF_PROVIDER"]
        #else
        let proofProvider: String? = nil
        #endif

        var wireText = trimmed
        var operatorText: String?
        if let collectFacts = turnFacts,
           let facts = await collectFacts(originalText),
           !facts.isEmpty {
            wireText = facts + "\n\n" + trimmed
            operatorText = originalText
        }

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
        return CreateAiInteractionInput(
            inputText: wireText,
            clientId: UUID().uuidString.lowercased(),
            threadId: threadId?.rawValue,
            newThread: threadId == nil ? true : nil,
            agentSlug: proofProvider == nil ? nil : "atlas",
            provider: proofProvider,
            sourceType: "app",
            payload: atlasMobileInteractionPayload(base: payload),
            uploadedImages: fields?.uploadedImages.isEmpty == false ? fields?.uploadedImages : nil,
            uploadedDocuments: fields?.uploadedDocuments.isEmpty == false ? fields?.uploadedDocuments : nil,
            richInputPayload: fields?.richInputPayload
        )
    }
}

@MainActor
extension ConversationModel {
    func uploadForSendTurn(
        sendingDrafts: [LocalDraft],
        longMessage: AtlasPreparedLongMessage,
        trimmed: String,
        assistantId: String
    ) async -> RichInputInteractionFields? {
        guard !sendingDrafts.isEmpty || longMessage.attachment != nil else { return nil }

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
            let fields = engine.interactionFields(images: uploaded.images,
                                                  documents: uploaded.documents,
                                                  inputText: trimmed)
            drafts.removeAll(); attachmentInputs.removeAll()
            uploadPercent = nil
            return fields
        } catch {
            for i in drafts.indices { drafts[i].state = .falhou("\(error)") }
            uploadPercent = nil
            update(assistantId) { $0.text = "⚠️ upload falhou: \(error)"; $0.streaming = false }
            isSending = false
            return nil
        }
    }
}

@MainActor
extension ConversationModel {
    func steerInteraction(
        traceId: TraceID,
        instruction: String,
        scope: AtlasInteractionSteerScope
    ) async {
        do {
            let receipt = try await client.steerAiInteraction(
                traceId.rawValue,
                input: .init(instruction: instruction, scope: scope)
            )
            lastSteerReceipt = receipt
            toast = receipt.isAccepted
                ? "Instrução enfileirada para o próximo checkpoint."
                : "Steering recusado: \(receipt.reason?.rawValue ?? "indisponível")."
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }
}

@MainActor
@Observable
final class ConversationModel {
    static let effortPreferenceKey = "atlas.composer.effort"
    static let draftPrefix = "atlas.conversation.draft."
    static let visitedPrefix = "atlas.conversation.lastVisit."

    var bubbles: [ChatBubble] = []
    var isSending = false
    var loadError: String?
    var loadFailureKind: AtlasNetworkFailureKind?
    var toast: String?
    var cacheCapturedAt: Date?
    var showingStaleCache = false
    var workspaceName: String?
    var workspaceSlug: String?
    var workspacePath: String?
    var drafts: [LocalDraft] = []
    var uploadPercent: Double?
    var queuedMessages: [QueuedMessage] = []
    var effort: AtlasComputeEffort
    var draftText: String = ""
    var firstNewBubbleId: String?
    var lastVisitAt: Date?
    let reviews: ChangeReviewModel
    var latestSurfaceHandoff: AtlasAiSurfaceHandoff?
    var lastSteerReceipt: AtlasInteractionSteerResponse?

    @ObservationIgnored var turnFacts: ((String) async -> String?)?

    @ObservationIgnored var taskKind: String?

    let client: AtlasClient
    var threadId: ThreadID?
    var activeRun: InteractionRun?
    var attachmentInputs: [String: AttachmentInput] = [:]
    @ObservationIgnored var pendingAttachmentPreparations: [String: PendingAttachmentPreparation] = [:]
    @ObservationIgnored let engine: AtlasRichInputEngine
    @ObservationIgnored let outbox: InteractionOutbox
    @ObservationIgnored let queueStore: QueuedFollowUpStore
    @ObservationIgnored let readCache: ThreadReadCache
    @ObservationIgnored var queueScope: String
    @ObservationIgnored var draftScope: String

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

}
