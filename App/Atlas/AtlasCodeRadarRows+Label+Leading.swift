import AtlasCore
import SwiftUI

// Leading stack — peel de AtlasCodeRadarRows+Label.
// Layout → AtlasCodeRadarRows+Label+Layout.swift

extension AtlasCodeRepoRow {
    var repoRowLeading: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 7) {
                Text(repo.name)
                    .atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                repoFolderBadge
            }
            repoRowIssues
        }
        .accessibilityHidden(true)
    }
}
