import SwiftUI
import AtlasCore

// Button row — peel de ChangeReviewRunActions.

extension ChangeReviewRunActions {
    @ViewBuilder
    func runActionButtonRow(available: [AtlasTraceChangeReview.Action]) -> some View {
        HStack(spacing: 10) {
            acceptButton(available: available)
            rejectButton(available: available)
            if applying { applyingIndicator }
        }
    }
}
