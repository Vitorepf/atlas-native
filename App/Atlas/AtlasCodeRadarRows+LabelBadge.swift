import AtlasCore
import SwiftUI

// Repo folder badge — peel de AtlasCodeRadarRows+Label.

extension AtlasCodeRepoRow {
    @ViewBuilder
    var repoFolderBadge: some View {
        if showsFolder, let folder = repo.folder {
            Text(folder)
                .atlasSans(10)
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 1.5)
                .background(Capsule().fill(AtlasTheme.surface))
                .accessibilityHidden(true)
        }
    }
}
