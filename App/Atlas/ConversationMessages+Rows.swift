import SwiftUI
import AtlasCore

// Bubble row — peel de ConversationMessages+List.
// Empty → ConversationMessages+Empty.swift

extension ConversationMessages {
    @ViewBuilder
    func bubbleRow(_ bubble: ChatBubble) -> some View {
        let traceArtifacts = bubble.traceId.flatMap { model.reviews.artifactsByTrace[$0] }
        let artifactItems = traceArtifacts?.state == .available ? traceArtifacts?.items ?? [] : []
        EditorialTurn(bubble: bubble, reduceMotion: reduceMotion,
                      onFeedback: { kind in Task { await model.feedback(bubble.id, kind) } },
                      onCopy: { onCopy(bubble.text, bubble.role == "user" ? "mensagem" : "resposta") },
                      onEditResend: { onEditResend(bubble) },
                      onStop: { model.cancel() },
                      onExecutionChoice: { jobId, optionId in
                          Task { await model.resolveExecutionChoice(jobId: jobId, optionId: optionId) }
                      },
                      onRetry: { jobId in
                          Task { await model.retryTurn(jobId: jobId) }
                      },
                      onSteer: { trace in steerTrace = ConversationSteerTraceRef(id: trace) },
                      artifactItems: artifactItems,
                      onOpenArtifacts: { trace in artifactTrace = ConversationReviewTraceRef(id: trace) })
        .equatable()
        .id(bubble.id)
        .task(id: bubble.traceId?.rawValue) {
            if bubble.role == "assistant", !bubble.streaming, let trace = bubble.traceId {
                await model.reviews.refreshChangeReview(traceId: trace)
            }
        }
    }
}
