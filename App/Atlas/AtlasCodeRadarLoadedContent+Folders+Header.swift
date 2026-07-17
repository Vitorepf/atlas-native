import AtlasCore
import SwiftUI

// Folders header — peel de AtlasCodeRadarLoadedContent+Folders.
// Loop → AtlasCodeRadarLoadedContent+Folders+Loop.swift

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarFoldersHeader: some View {
        if !workspace.folders.isEmpty {
            AtlasCodeRadarSectionLabel(text: "PASTAS", accessibilityID: A11yID.radarFolders)
                .padding(.top, 22)
        }
    }
}
