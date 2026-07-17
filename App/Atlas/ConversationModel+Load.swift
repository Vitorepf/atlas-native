import Foundation
import AtlasCore

/// Hidratação da thread e cancelamento/feedback — fora do shell principal.
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
