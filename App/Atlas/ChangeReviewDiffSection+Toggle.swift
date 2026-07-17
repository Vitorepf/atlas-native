import SwiftUI
import AtlasCore

// Toggle diff — peel de ChangeReviewPatchCard.
// Risk → ChangeReviewDiffSection+RiskFlags.swift

extension ChangeReviewPatchCard {
    func toggleDiff() {
        if diffExpanded {
            expandedDiffPatch = nil
        } else {
            expandedDiffPatch = patch.id
            Task { await reviews.refreshChangeReviewDiff(traceId: traceId, patchId: patch.patchID) }
        }
    }
}
