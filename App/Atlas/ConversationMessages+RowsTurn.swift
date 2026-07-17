import SwiftUI
import AtlasCore

// Bubble row editorial turn — peel de ConversationMessages+Rows.

extension ConversationMessages {
    func editorialTurn(for bubble: ChatBubble, artifactItems: [AtlasTraceArtifacts.Item]) -> EditorialTurn {
        EditorialTurn(
            bubble: bubble,
            reduceMotion: reduceMotion,
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
            onOpenArtifacts: { trace in artifactTrace = ConversationReviewTraceRef(id: trace) }
        )
    }
}
