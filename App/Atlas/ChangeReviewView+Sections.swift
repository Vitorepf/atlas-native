import SwiftUI
import AtlasCore

// Sections stack — peel de ChangeReviewView+Available.
// Tail → ChangeReviewView+SectionsTail.swift

extension ChangeReviewAvailableContent {
    @ViewBuilder
    var reviewSections: some View {
        if let run = review.run { ChangeReviewRunHeader(run: run) }
        ChangeReviewGovernanceSection(reviews: reviews, traceId: traceId)
        reviewPatchTail
    }
}
