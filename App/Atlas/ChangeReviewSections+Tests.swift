import SwiftUI
import AtlasCore

// Testes — peel de ChangeReviewSections+Checks.
// Row → ChangeReviewSections+TestRow.swift

struct ChangeReviewTestsSection: View {
    let tests: [AtlasTraceChangeReview.TestRun]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("TESTES · \(tests.count)")
            ForEach(tests) { t in
                testRow(t)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenTestsSection(tests))
        .accessibilityIdentifier(A11yID.reviewTestsSection)
    }
}
