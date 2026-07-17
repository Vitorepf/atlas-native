import SwiftUI
import AtlasCore

// Stack do turno assistente — peel de EditorialTurn (régua ≤100).
// Closing → EditorialTurn+Closing.swift
// Execution → EditorialTurn+AssistantExecution.swift

extension EditorialTurn {
    @ViewBuilder
    var assistantTurn: some View {
        VStack(alignment: .leading, spacing: 12) {
            // O PLANO da obra: durante a execução, o roteiro é percorrido
            // ao vivo (done/atual/pendente); depois, fica como prova.
            PlanCard(bubble: bubble)
            if bubble.streaming, bubble.hasLiveExecutionSurface {
                ExecutionRibbon(bubble: bubble, reduceMotion: reduceMotion, onStop: onStop)
            }
            assistantExecutionBlock
            assistantClosing
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.38) { onCopy() }
        .accessibilityHint(EditorialTurnA11y.copyLongPressHint)
    }
}
