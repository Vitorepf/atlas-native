import AtlasCore
import SwiftUI

// Folder toggle button — peel de AtlasCodeRadarFolderRow.
// A11y → AtlasCodeRadarFolderRow+Toggle+A11y.swift

extension AtlasCodeFolderRow {
    var folderToggleButton: some View {
        folderToggleA11y(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onToggle()
            } label: {
                folderHeaderLabel
            }
            .buttonStyle(.plain)
        )
    }
}
