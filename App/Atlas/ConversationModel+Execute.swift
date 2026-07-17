import SwiftUI
import AtlasCore

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
