import AtlasCore
import SwiftUI

// Repo row issues — peel de AtlasCodeRadarRows+Label.
// Trailing → AtlasCodeRadarRows+LabelTrailing.swift

extension AtlasCodeRepoRow {
    @ViewBuilder
    var repoRowIssues: some View {
        if let issues, let first = issues.first {
            HStack(spacing: 6) {
                Circle()
                    .fill(first.isSevere ? AtlasCodePalette.alert : AtlasCodePalette.alert.opacity(0.45))
                    .frame(width: 4.5, height: 4.5)
                    .accessibilityHidden(true)
                Text(issues.count == 1 ? first.headline(trunk: trunk) : "\(first.headline(trunk: trunk)) · +\(issues.count - 1)")
                    .font(.system(size: 12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        }
    }
}
