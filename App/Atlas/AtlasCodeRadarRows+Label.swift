import AtlasCore
import SwiftUI

// Conteúdo da linha de repo — peel de AtlasCodeRadarRows.
// Issues/trailing → AtlasCodeRadarRows+LabelExtras.swift
// Badge → AtlasCodeRadarRows+LabelBadge.swift

extension AtlasCodeRepoRow {
    var repoRowLabel: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(repo.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    repoFolderBadge
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
