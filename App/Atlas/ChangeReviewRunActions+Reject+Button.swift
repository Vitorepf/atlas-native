import SwiftUI
import AtlasCore

// Reject button chrome — peel de ChangeReviewRunActions+Reject.

extension ChangeReviewRunActions {
    @ViewBuilder
    func rejectButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.reject) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                rejectReviewAction()
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
