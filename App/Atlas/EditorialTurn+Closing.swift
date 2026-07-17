import SwiftUI
import AtlasCore

// Fechamento do turno (prova / markdown / feedback) — peel de EditorialTurn+Assistant.
// Tail → EditorialTurn+ClosingTail.swift

extension EditorialTurn {
    @ViewBuilder
    var assistantClosing: some View {
        if !bubble.streaming,
           ExecutionProof.shouldDisplay(bubble: bubble, artifactItems: artifactItems) {
            ExecutionProof(bubble: bubble, artifactItems: artifactItems, onOpenArtifacts: onOpenArtifacts)
            Text("RESPOSTA FINAL")
                .font(.system(.caption2, weight: .semibold)).tracking(1.6)
                .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .accessibilityLabel(EditorialTurnA11y.spokenFinalAnswerKicker)
                .accessibilityAddTraits(.isHeader)
        }
        assistantClosingTail
    }
}
