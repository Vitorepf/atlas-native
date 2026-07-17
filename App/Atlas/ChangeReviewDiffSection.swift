import SwiftUI
import AtlasCore

// MARK: - Patch / Diff (C15 · C16)
// DiffView → ChangeReviewDiffView.swift · Toggle → +Toggle · Header → +Header

struct ChangeReviewPatchCard: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Binding var expandedDiffPatch: String?
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var diffExpanded: Bool { expandedDiffPatch == patch.id }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            patchHeader
            ForEach(patch.changedFiles + patch.createdFiles + patch.deletedFiles, id: \.self) { file in
                ChangeReviewFileRow(reviews: reviews, traceId: traceId, patch: patch, file: file)
            }
            patchRiskFlags
            if diffExpanded {
                ChangeReviewDiffView(reviews: reviews, traceId: traceId, patch: patch)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewPatchA11y.spokenCard(patch: patch, diffExpanded: diffExpanded))
        .accessibilityIdentifier(A11yID.reviewPatchCard(patch.id))
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: diffExpanded)
    }
}
