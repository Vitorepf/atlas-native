import SwiftUI
import AtlasCore

/// Decisões já registradas — peel de ChangeReviewSections (régua ≤100).

struct ChangeReviewDecidedSection: View {
    let actions: [AtlasTraceChangeReview.OperatorAction]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("DECISÕES REGISTRADAS")
            ForEach(actions) { a in
                HStack(spacing: 8) {
                    Text(a.action == .accept ? "aceito" : "rejeitado")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(a.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                    if let at = a.actedAt {
                        Text(at).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    Spacer()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(ChangeReviewSectionsA11y.spokenDecidedAction(a))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenDecidedSection(actions))
        .accessibilityIdentifier(A11yID.reviewDecidedSection)
    }
}
