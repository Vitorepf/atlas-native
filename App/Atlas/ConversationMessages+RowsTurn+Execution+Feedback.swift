import SwiftUI
import AtlasCore

// Feedback/copy callbacks — peel de ConversationMessages+RowsTurn+Execution.

extension ConversationMessages {
    func editorialTurnFeedbackCallbacks(for bubble: ChatBubble) -> (
        onFeedback: (FeedbackKind) -> Void,
        onCopy: () -> Void,
        onEditResend: () -> Void
    ) {
        (
            onFeedback: { kind in Task { await model.feedback(bubble.id, kind) } },
            onCopy: { onCopy(bubble.text, bubble.role == "user" ? "mensagem" : "resposta") },
            onEditResend: { onEditResend(bubble) }
        )
    }
}
