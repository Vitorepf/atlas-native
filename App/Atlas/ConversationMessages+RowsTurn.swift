import SwiftUI
import AtlasCore

// Bubble row editorial turn — peel de ConversationMessages+Rows.
// Execution → ConversationMessages+RowsTurn+Execution.swift
// SteerArtifacts → ConversationMessages+RowsTurn+SteerArtifacts.swift

extension ConversationMessages {
    func editorialTurn(for bubble: ChatBubble, artifactItems: [AtlasTraceArtifacts.Item]) -> EditorialTurn {
        let exec = editorialTurnExecutionCallbacks(for: bubble)
        let steer = editorialTurnSteerArtifactsCallbacks()
        return EditorialTurn(
            bubble: bubble,
            reduceMotion: reduceMotion,
            onFeedback: exec.onFeedback,
            onCopy: exec.onCopy,
            onEditResend: exec.onEditResend,
            onStop: exec.onStop,
            onExecutionChoice: exec.onExecutionChoice,
            onRetry: exec.onRetry,
            onSteer: steer.onSteer,
            artifactItems: artifactItems,
            onOpenArtifacts: steer.onOpenArtifacts
        )
    }
}
