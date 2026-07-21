import SwiftUI
import AtlasCore

// Folder title stack — peel de AtlasCodeRadarFolderRow+Header.

extension AtlasCodeFolderRow {
    var folderTitleStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Mesma voz das linhas irmãs (repo=medium, pasta=semibold): serif
            // é masthead/título — linha de lista fala em sans (canon §C).
            Text(folder.name)
                .atlasSans(15, .semibold)
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(folder.repositories == 1 ? "1 repositório" : "\(folder.repositories) repositórios")
                .atlasSans(11.5)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .accessibilityHidden(true)
    }
}
