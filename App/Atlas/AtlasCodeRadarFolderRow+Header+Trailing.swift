import SwiftUI
import AtlasCore

// Folder header trailing — peel de AtlasCodeRadarFolderRow+Header.

extension AtlasCodeFolderRow {
    var folderHeaderTrailing: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 6)
            exceptionBadge
            folderHeaderChevron
        }
    }
}
