import SwiftUI
import AtlasCore

// Patch cards + actions do review — peel de ChangeReviewView+Sections.
// After → ChangeReviewView+SectionsAfter.swift

extension ChangeReviewAvailableContent {
    @ViewBuilder
    var reviewPatchTail: some View {
        ForEach(review.patches) { patch in
            ChangeReviewPatchCard(
                reviews: reviews,
                traceId: traceId,
                patch: patch,
                expandedDiffPatch: $expandedDiffPatch
            )
        }
        reviewSectionsAfterPatches
    }
}
