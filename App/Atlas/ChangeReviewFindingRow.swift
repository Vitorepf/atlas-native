import SwiftUI
import AtlasCore

/// Linha de achado — peel de ChangeReviewFindingsSection.
/// A11y → ChangeReviewFindingRow+A11y.swift
/// Body → ChangeReviewFindingRow+Body.swift

struct ChangeReviewFindingRow: View {
    let finding: AtlasTraceChangeReview.Finding

    var body: some View {
        findingBody
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(rowAccessibilityLabel)
            .accessibilityIdentifier(A11yID.reviewFindingRow(finding.id))
    }
}
