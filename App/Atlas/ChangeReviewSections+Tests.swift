import SwiftUI
import AtlasCore

// Testes — peel de ChangeReviewSections+Checks.

struct ChangeReviewTestsSection: View {
    let tests: [AtlasTraceChangeReview.TestRun]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("TESTES · \(tests.count)")
            ForEach(tests) { t in
                HStack(spacing: 8) {
                    Text(t.command ?? "teste").font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                        .accessibilityHidden(true)
                    Spacer()
                    Text(t.status).font(AtlasFont.mono(10))
                        .foregroundStyle(t.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(ChangeReviewSectionsA11y.spokenTest(t))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenTestsSection(tests))
        .accessibilityIdentifier(A11yID.reviewTestsSection)
    }
}
