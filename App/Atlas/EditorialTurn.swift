import SwiftUI
import AtlasCore

// Turno editorial — extraído de ConversationChrome (CICLO B compressão).
// Assinatura/feedback → EditorialTurnChrome; empty/failure → ConversationEmptyStates.

struct EditorialTurn: View, Equatable {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    let onCopy: () -> Void
    var onEditResend: () -> Void = {}
    let onStop: () -> Void
    let onExecutionChoice: (JobID, String) -> Void
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (TraceID) -> Void = { _ in }
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @State private var placed = false

    // F2.10: igualdade só no que a tela mostra — closures recriadas pelo pai
    // não invalidam o subtree (pare com `.equatable()` no call site).
    nonisolated static func == (lhs: EditorialTurn, rhs: EditorialTurn) -> Bool {
        lhs.bubble == rhs.bubble && lhs.reduceMotion == rhs.reduceMotion && lhs.artifactItems == rhs.artifactItems
    }

    var body: some View {
        Group {
            if bubble.role == "user" {
                userTurn
            } else {
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
            }
        }
        .opacity(placed ? 1 : 0)
        .offset(y: placed ? 0 : 12)
        .onAppear {
            if reduceMotion { placed = true }
            else { withAnimation(AtlasMotion.arrival) { placed = true } }
        }
    }
}
