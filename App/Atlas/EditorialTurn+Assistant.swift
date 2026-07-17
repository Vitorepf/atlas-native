import SwiftUI
import AtlasCore

// Stack do turno assistente — peel de EditorialTurn (régua ≤100).

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
            if let state = bubble.executionPresentationState {
                let steerTrace = bubble.executionPresence?.isOngoing == true ? bubble.traceId : nil
                if ExecutionStateCard.shouldDisplay(state: state) {
                    ExecutionStateCard(
                        state: state,
                        jobId: bubble.executionChoiceJobId,
                        onChoose: onExecutionChoice,
                        retryableJobId: bubble.retryableJobId,
                        onRetry: onRetry,
                        onSteer: steerTrace.map { trace in { onSteer(trace) } }
                    )
                }
            }
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.38) { onCopy() }
        .accessibilityHint(EditorialTurnA11y.copyLongPressHint)
    }
}
