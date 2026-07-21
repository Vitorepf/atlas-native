import SwiftUI
import AtlasCore

// Folder header leading — peel de AtlasCodeRadarFolderRow+Header.

extension AtlasCodeFolderRow {
    var folderHeaderLeading: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder")
                .atlasSans(15)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 20)
                .accessibilityHidden(true)
            folderTitleStack
        }
    }
}
