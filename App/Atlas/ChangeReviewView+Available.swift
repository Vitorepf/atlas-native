import SwiftUI
import AtlasCore

/// Scroll de revisão disponível — peel de ChangeReviewView.
/// Sections → ChangeReviewView+Sections.swift
struct ChangeReviewAvailableContent: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let review: AtlasTraceChangeReview
    @Binding var expandedDiffPatch: String?
    @Binding var applying: Bool

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                reviewSections
            }
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 14)
            .accessibilityElement(children: .contain)
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel("revisão de mudanças")
        .accessibilityIdentifier(A11yID.reviewAvailableContent)
    }
}
