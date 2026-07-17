import SwiftUI
import AtlasCore

// Botão Rejeitar — peel de ChangeReviewRunActions+Buttons.

extension ChangeReviewRunActions {
    @ViewBuilder
    func rejectButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.reject) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
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
    }
}
