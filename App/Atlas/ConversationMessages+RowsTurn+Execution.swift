import SwiftUI
import AtlasCore

// Execution callbacks — peel de ConversationMessages+RowsTurn.
// Feedback → ConversationMessages+RowsTurn+Execution+Feedback.swift
// Run → ConversationMessages+RowsTurn+Execution+Run.swift

extension ConversationMessages {
    func editorialTurnExecutionCallbacks(for bubble: ChatBubble) -> (
        onFeedback: (FeedbackKind) -> Void,
        onCopy: () -> Void,
        onEditResend: () -> Void,
        onStop: () -> Void,
        onExecutionChoice: (JobID, String) -> Void,
        onRetry: (JobID) -> Void
    ) {
        let feedback = editorialTurnFeedbackCallbacks(for: bubble)
        let run = editorialTurnRunCallbacks()
        return (
            onFeedback: feedback.onFeedback,
            onCopy: feedback.onCopy,
            onEditResend: feedback.onEditResend,
            onStop: run.onStop,
            onExecutionChoice: run.onExecutionChoice,
            onRetry: run.onRetry
        )
    }
}
