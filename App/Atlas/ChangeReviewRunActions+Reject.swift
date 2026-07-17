import SwiftUI
import AtlasCore

// Botão Rejeitar — peel de ChangeReviewRunActions+Buttons.
// Label → ChangeReviewRunActions+Reject+Label.swift

extension ChangeReviewRunActions {
    @ViewBuilder
    func rejectButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.reject) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                applying = true
                Task { await reviews.applyChangeReview(traceId: traceId, action: .reject); applying = false }
            } label: {
                rejectButtonLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("rejeitar revisão inteira")
            .accessibilityHint("rejeita o run de engenharia desta execução")
            .accessibilityIdentifier(A11yID.reviewRunReject)
        }
    }
}
