import SwiftUI
import AtlasCore

// Change-review gate — peel de ConversationMessages+ChangeReview.

extension ConversationMessages {
    func showsChangeReviewChip(for bubble: ChatBubble) -> Bool {
        bubble.role == "assistant"
            && !bubble.streaming
            && bubble.traceId != nil
            && model.reviews.changeReviewsByTrace[bubble.traceId!]?.state == .available
            && ChangeReviewSheet.hasReviewSurface(
                model.reviews.changeReviewsByTrace[bubble.traceId!]!
            )
    }
}
