import AtlasCore
import SwiftUI

// Conteúdo da linha de repo — peel de AtlasCodeRadarRows.
// Issues/trailing → AtlasCodeRadarRows+LabelExtras.swift

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
                repoRowIssues
            }
            .accessibilityHidden(true)
            Spacer(minLength: 6)
            repoRowTrailing
        }
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}
