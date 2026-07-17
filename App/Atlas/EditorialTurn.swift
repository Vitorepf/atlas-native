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
                VStack(alignment: .leading, spacing: 8) {
                    Text(""\(bubble.text)"")
                        .font(AtlasFont.serifItalic(18)).lineSpacing(8).foregroundStyle(AtlasTheme.textPrimary)
                        .padding(.leading, 16)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                        }
                    Button(action: onEditResend) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.turn.down.right")
                                .font(.system(size: 10, weight: .semibold))
                            Text("editar e reenviar")
                                .font(AtlasFont.mono(10))
                        }
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
                    }
                    .buttonStyle(PressableScale())
                    .accessibilityLabel("editar esta mensagem e reenviar como novo turno")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
                        SignatureLine(provider: bubble.provider, model: bubble.model, elapsedMs: bubble.elapsedMs)
                        FeedbackRow(active: bubble.feedbackAction, onFeedback: onFeedback)
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
