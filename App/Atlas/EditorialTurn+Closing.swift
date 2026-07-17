import SwiftUI
import AtlasCore

// Fechamento do turno (prova / markdown / feedback) — peel de EditorialTurn+Assistant.

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
        if !bubble.text.isEmpty {
            AtlasMarkdownView(text: bubble.text, streaming: bubble.streaming)
        }
        if !bubble.streaming {
            if SignatureLine.shouldDisplay(provider: bubble.provider, model: bubble.model) {
                SignatureLine(
                    provider: bubble.provider, model: bubble.model,
                    elapsedMs: bubble.elapsedMs, reduceMotion: reduceMotion)
            }
            FeedbackRow(active: bubble.feedbackAction, reduceMotion: reduceMotion, onFeedback: onFeedback)
        }
    }
}
