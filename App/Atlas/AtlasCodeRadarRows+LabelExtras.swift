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
                // "+1" era críptico: diz o que é ("mais 1 alerta"), não só o número.
                Text(issues.count == 1 ? first.headline(trunk: trunk) : "\(first.headline(trunk: trunk)) · mais \(issues.count - 1) alerta\(issues.count - 1 == 1 ? "" : "s")")
                    .font(.system(size: 12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        }
    }
}
