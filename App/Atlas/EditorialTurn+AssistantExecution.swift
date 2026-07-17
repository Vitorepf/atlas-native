import SwiftUI
import AtlasCore

// Execution state block — peel de EditorialTurn+Assistant.
// Card → EditorialTurn+AssistantExecutionCard.swift

extension EditorialTurn {
    @ViewBuilder
    var assistantExecutionBlock: some View {
        if let state = bubble.executionPresentationState {
            assistantExecutionCard(state)
        }
    }
}
