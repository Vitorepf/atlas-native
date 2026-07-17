import SwiftUI
import AtlasCore

// Stack do turno assistente — peel de EditorialTurn (régua ≤100).
// Closing → EditorialTurn+Closing.swift
// Execution → EditorialTurn+AssistantExecution.swift
// Plan → EditorialTurn+AssistantPlan.swift · Ribbon → EditorialTurn+AssistantRibbon.swift

extension EditorialTurn {
    @ViewBuilder
    var assistantTurn: some View {
        VStack(alignment: .leading, spacing: 12) {
            assistantPlanCard
            assistantExecutionRibbon
            assistantExecutionBlock
            assistantClosing
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.38) { onCopy() }
        .accessibilityHint(EditorialTurnA11y.copyLongPressHint)
    }
}
