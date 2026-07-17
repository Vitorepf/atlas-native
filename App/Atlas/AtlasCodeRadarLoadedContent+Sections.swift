import AtlasCore
import SwiftUI

// Radar sections stack — peel de AtlasCodeRadarLoadedContent.
// Recents → AtlasCodeRadarLoadedContent+Sections+Recents.swift

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarSections: some View {
        AtlasCodeRadarStatusCapsule(model: model)
            .padding(.bottom, 18)

        radarRecentsSection

        radarFoldersAndLoose
    }
}
