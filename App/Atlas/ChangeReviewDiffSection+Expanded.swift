import SwiftUI
import AtlasCore

// Diff expand predicate — peel de ChangeReviewDiffSection.

extension ChangeReviewPatchCard {
    var diffExpanded: Bool { expandedDiffPatch == patch.id }
}
