import SwiftUI
import AtlasCore

/// Aceitar o run = aceitar todos os arquivos capturados e depois o run —
/// semântica do servidor; o botão só existe se a ação estiver disponível.
struct ChangeReviewRunActions: View {
    let review: AtlasTraceChangeReview
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Binding var applying: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let available = review.review.availableActions
        if !available.isEmpty {
            HStack(spacing: 10) {
                if available.contains(.accept) {
                    Button {
                        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                        applying = true
                        Task { await reviews.applyChangeReview(traceId: traceId, action: .accept); applying = false }
                    } label: {
                        Text("Aceitar tudo")
                            .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(Capsule().fill(AtlasTheme.accent))
                    }
                    .buttonStyle(PressableScale())
                    .accessibilityLabel("aceitar todos os arquivos e concluir revisão")
                    .accessibilityHint("aceita cada arquivo capturado e depois conclui o run")
                    .accessibilityIdentifier(A11yID.reviewRunAccept)
                }
                if available.contains(.reject) {
                    Button {
                        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                        applying = true
                        Task { await reviews.applyChangeReview(traceId: traceId, action: .reject); applying = false }
                    } label: {
                        Text("Rejeitar")
                            .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.domOperacional)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
                            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
                    }
                    .buttonStyle(PressableScale())
                    .accessibilityLabel("rejeitar revisão inteira")
                    .accessibilityHint("rejeita o run de engenharia desta execução")
                    .accessibilityIdentifier(A11yID.reviewRunReject)
                }
                if applying { applyingIndicator }
            }
            .disabled(applying)
            .padding(.top, 4)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: applying)
        }
    }

    @ViewBuilder
    private var applyingIndicator: some View {
        if reduceMotion {
            Text("registrando…")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel("registrando decisão")
        } else {
            ProgressView()
                .tint(AtlasTheme.accent)
                .accessibilityLabel("registrando decisão")
        }
    }
}
