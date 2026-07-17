import SwiftUI
import AtlasCore

// Empty + bubble row — peel de ConversationMessages+List.

extension ConversationMessages {
    @ViewBuilder
    func emptyMessages() -> some View {
        if model.loadError != nil {
            AtlasNetworkFailureEmpty(
                kind: model.loadFailureKind,
                hasToken: session.hasToken,
                host: session.host,
                topPadding: 100,
                retryHint: "reconecta e recarrega esta conversa",
                accessibilityIdentifier: A11yID.conversationLoadFailure,
                onRetry: { Task { await model.load() } }
            )
        } else {
            EmptyConversation(
                reduceMotion: reduceMotion,
                prompt: emptyPrompt,
                suggestions: emptySuggestions
            ) { suggestion in
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                let effort = model.effort
                Task { await model.send(suggestion, effort: effort) }
            }
        }
    }

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
