import SwiftUI
import AtlasCore

// Controles — peel de ChangeReviewSections.
// Testes → ChangeReviewSections+Tests.swift

struct ChangeReviewControlsSection: View {
    let controls: [AtlasTraceChangeReview.Control]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("CONTROLES · \(controls.count)")
            ForEach(controls) { c in
                HStack(spacing: 8) {
                    Text(c.slug).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityHidden(true)
                    Text(c.status).font(AtlasFont.mono(10))
                        .foregroundStyle(c.status == "pass" || c.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                    Spacer()
                    Text(c.signalSummary).font(.caption2).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(ChangeReviewSectionsA11y.spokenControl(c))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenControlsSection(controls))
        .accessibilityIdentifier(A11yID.reviewControlsSection)
    }
}
