import SwiftUI
import AtlasCore

// Controles — peel de ChangeReviewSections.
// Testes → ChangeReviewSections+Tests.swift
// Row → ChangeReviewSections+ControlRow.swift

struct ChangeReviewControlsSection: View {
    let controls: [AtlasTraceChangeReview.Control]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("CONTROLES · \(controls.count)")
            ForEach(controls) { c in
                controlRow(c)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenControlsSection(controls))
        .accessibilityIdentifier(A11yID.reviewControlsSection)
    }
}
