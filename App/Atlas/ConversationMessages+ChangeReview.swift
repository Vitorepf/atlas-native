import SwiftUI
import AtlasCore

// Change-review chip — peel de ConversationMessages (régua ≤100).
// Label → ConversationMessages+ChangeReviewLabel.swift

extension ConversationMessages {
    @ViewBuilder
    func changeReviewChip(for bubble: ChatBubble) -> some View {
        if bubble.role == "assistant", !bubble.streaming,
           let trace = bubble.traceId,
           let review = model.reviews.changeReviewsByTrace[trace],
           review.state == .available,
           ChangeReviewSheet.hasReviewSurface(review) {
            Button { reviewTrace = ConversationReviewTraceRef(id: trace) } label: {
                changeReviewChipLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(ConversationMessagesA11y.spokenChangeReview(patchCount: review.patches.count))
            .accessibilityHint(ConversationMessagesA11y.changeReviewHint)
            .accessibilityIdentifier(A11yID.reviewChip(trace.rawValue))
        }
    }
}
