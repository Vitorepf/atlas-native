import AtlasCore
import SwiftUI

// Repo row issues + trailing — peel de AtlasCodeRadarRows+Label.

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

    @ViewBuilder
    var repoRowTrailing: some View {
        if let age = AtlasCodeAge.short(from: repo.lastCommitAt) {
            Text(age)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            .accessibilityHidden(true)
    }
}
