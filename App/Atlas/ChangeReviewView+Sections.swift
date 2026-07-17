import SwiftUI
import AtlasCore

// Sections stack — peel de ChangeReviewView+Available.

extension ChangeReviewAvailableContent {
    @ViewBuilder
    var reviewSections: some View {
        if let run = review.run { ChangeReviewRunHeader(run: run) }
        ChangeReviewGovernanceSection(reviews: reviews, traceId: traceId)
        ForEach(review.patches) { patch in
            ChangeReviewPatchCard(
                reviews: reviews,
                traceId: traceId,
                patch: patch,
                expandedDiffPatch: $expandedDiffPatch
            )
        }
        if !review.controls.isEmpty { ChangeReviewControlsSection(controls: review.controls) }
        if !review.testRuns.isEmpty { ChangeReviewTestsSection(tests: review.testRuns) }
        if !review.review.findings.isEmpty { ChangeReviewFindingsSection(findings: review.review.findings) }
        if !review.review.operatorActions.isEmpty {
            ChangeReviewDecidedSection(actions: review.review.operatorActions)
        }
        ChangeReviewRunActions(
            review: review,
            reviews: reviews,
            traceId: traceId,
            applying: $applying
        )
    }
}
