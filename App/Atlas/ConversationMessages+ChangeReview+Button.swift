import SwiftUI
import AtlasCore

// Change-review button — peel de ConversationMessages+ChangeReview.

extension ConversationMessages {
    @ViewBuilder
    func changeReviewChipButton(for bubble: ChatBubble, trace: TraceID) -> some View {
        Button { reviewTrace = ConversationReviewTraceRef(id: trace) } label: {
            changeReviewChipLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(
            ConversationMessagesA11y.spokenChangeReview(
                patchCount: model.reviews.changeReviewsByTrace[trace]!.patches.count
            )
        )
        .accessibilityHint(ConversationMessagesA11y.changeReviewHint)
        .accessibilityIdentifier(A11yID.reviewChip(trace.rawValue))
    }
}
