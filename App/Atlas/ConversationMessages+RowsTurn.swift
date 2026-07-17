import SwiftUI
import AtlasCore

// Bubble row editorial turn — peel de ConversationMessages+Rows.
// Execution → ConversationMessages+RowsTurn+Execution.swift
// SteerArtifacts → ConversationMessages+RowsTurn+SteerArtifacts.swift
// Assembly → ConversationMessages+RowsTurn+Assembly.swift

extension ConversationMessages {
    func editorialTurn(for bubble: ChatBubble, artifactItems: [AtlasTraceArtifacts.Item]) -> EditorialTurn {
        editorialTurnAssembly(
            bubble: bubble,
            artifactItems: artifactItems,
            exec: editorialTurnExecutionCallbacks(for: bubble),
            steer: editorialTurnSteerArtifactsCallbacks()
        )
    }
}
