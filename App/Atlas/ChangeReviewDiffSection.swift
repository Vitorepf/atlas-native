import AtlasCore
import SwiftUI

// Cycle 040 fuse → ChangeReviewDiffSection.swift

// MARK: - Patch / Diff (C15 · C16)

struct ChangeReviewPatchCard: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Binding var expandedDiffPatch: String?
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        patchCardShell
    }
}
