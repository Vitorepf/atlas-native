import AtlasCore
import SwiftUI

// Folder toggle a11y — peel de AtlasCodeRadarFolderRow+Toggle.

extension AtlasCodeFolderRow {
    func folderToggleA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                AtlasCodeFolderRowA11y.spokenFolder(
                    name: folder.name,
                    repositoryCount: folder.repositories,
                    verifiedExceptionCount: verifiedExceptionCount,
                    isExpanded: isExpanded
                )
            )
            .accessibilityHint(AtlasCodeFolderRowA11y.spokenHint(isExpanded: isExpanded))
            .accessibilityIdentifier(A11yID.radarFolder(folder.slug))
    }
}
