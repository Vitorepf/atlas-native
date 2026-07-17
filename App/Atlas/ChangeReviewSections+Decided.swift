import SwiftUI
import AtlasCore

/// Decisões já registradas — peel de ChangeReviewSections (régua ≤100).
/// Row → ChangeReviewSections+DecidedRow.swift

struct ChangeReviewDecidedSection: View {
    let actions: [AtlasTraceChangeReview.OperatorAction]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("DECISÕES REGISTRADAS")
            ForEach(actions) { a in
                decidedActionRow(a)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenDecidedSection(actions))
        .accessibilityIdentifier(A11yID.reviewDecidedSection)
    }
}
