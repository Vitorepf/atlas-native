import AtlasCore
import SwiftUI

// Folder toggle button — peel de AtlasCodeRadarFolderRow.

extension AtlasCodeFolderRow {
    var folderToggleButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onToggle()
        } label: {
            folderHeaderLabel
        }
        .buttonStyle(.plain)
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
