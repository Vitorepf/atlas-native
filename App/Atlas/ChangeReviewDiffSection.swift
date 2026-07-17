import SwiftUI
import AtlasCore

// MARK: - Patch / Diff (C15 · C16)
// DiffView → ChangeReviewDiffView.swift · Toggle → +Toggle · Header → +Header
// Chrome → ChangeReviewDiffSection+Chrome.swift
// Body → ChangeReviewDiffSection+Body.swift

struct ChangeReviewPatchCard: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Binding var expandedDiffPatch: String?
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var diffExpanded: Bool { expandedDiffPatch == patch.id }

    var body: some View {
        patchCardChrome { patchCardBody }
    }
}
