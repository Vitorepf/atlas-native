import AtlasCore
import SwiftUI

// Conteúdo da linha de repo — peel de AtlasCodeRadarRows.

extension AtlasCodeRepoRow {
    var repoRowLabel: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(repo.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    if showsFolder, let folder = repo.folder {
                        Text(folder)
                            .font(.system(size: 10))
                            .foregroundStyle(AtlasTheme.textTertiary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1.5)
                            .background(Capsule().fill(AtlasTheme.surface))
                            .accessibilityHidden(true)
                    }
                }
                // A história do repo em português — só quando existe.
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
            .accessibilityHidden(true)
            Spacer(minLength: 6)
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
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}
