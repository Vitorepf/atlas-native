import SwiftUI
import AtlasCore

// Available review surface — peel de ChangeReviewView+Content.
// Empty/unavailable → ChangeReviewView+AvailableEmpty.swift

extension ChangeReviewSheet {
    @ViewBuilder
    func reviewAvailableContent(_ review: AtlasTraceChangeReview) -> some View {
        switch review.state {
        case .unavailable:
            reviewUnavailableContent(review)
        case .available:
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
}
