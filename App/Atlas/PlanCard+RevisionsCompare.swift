import SwiftUI
import AtlasCore

// Diff comparison body — peel de PlanCard+Revisions.
// Left → PlanCard+RevisionsCompare+Left.swift · Entered → +RevisionsCompare+Entered.swift

extension PlanRevisionCompare {
    @ViewBuilder
    var comparisonBody: some View {
        if let comparison = latestComparison, comparison.hasChanges {
            VStack(alignment: .leading, spacing: 7) {
                Text("v\(comparison.revision.revision) arquivado → plano atual")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                comparisonLeftList
                comparisonEnteredList
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(comparisonAccessibilityLabel(comparison))
        }
    }
}
