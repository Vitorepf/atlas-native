import SwiftUI
import AtlasCore

/// Scroll de revisão disponível — peel de ChangeReviewView.
struct ChangeReviewAvailableContent: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let review: AtlasTraceChangeReview
    @Binding var expandedDiffPatch: String?
    @Binding var applying: Bool

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
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
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 14)
            .accessibilityElement(children: .contain)
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel("revisão de mudanças")
        .accessibilityIdentifier(A11yID.reviewAvailableContent)
    }
}
