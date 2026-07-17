import SwiftUI
import AtlasCore

// Diff comparison body — peel de PlanCard+Revisions.

extension PlanRevisionCompare {
    @ViewBuilder
    var comparisonBody: some View {
        if let comparison = latestComparison, comparison.hasChanges {
            VStack(alignment: .leading, spacing: 7) {
                Text("v\(comparison.revision.revision) arquivado → plano atual")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                if !comparison.left.isEmpty {
                    revisionList(label: "saíram", items: comparison.left, tone: .removed)
                }
                if !comparison.entered.isEmpty {
                    revisionList(label: "entraram", items: comparison.entered, tone: .added)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(comparisonAccessibilityLabel(comparison))
        }
    }
}
