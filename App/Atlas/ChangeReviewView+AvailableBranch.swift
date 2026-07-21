import SwiftUI
import AtlasCore

// Available branch — peel de ChangeReviewView+Available.

extension ChangeReviewSheet {
    @ViewBuilder
    func reviewAvailableBranch(_ review: AtlasTraceChangeReview) -> some View {
        if Self.hasReviewSurface(review) {
            ChangeReviewAvailableContent(
                reviews: reviews,
                traceId: traceId,
                review: review,
                expandedDiffPatch: $expandedDiffPatch,
                applying: $applying
            )
        } else {
            reviewEmptySurface()
        }
    }
}
