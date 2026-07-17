import AtlasCore
import SwiftUI

// Radar folders — peel de AtlasCodeRadarLoadedContent+Sections.
// Header → AtlasCodeRadarLoadedContent+Folders+Header.swift
// Loop → AtlasCodeRadarLoadedContent+Folders+Loop.swift
// Loose → AtlasCodeRadarLoadedContent+Loose.swift

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarFoldersAndLoose: some View {
        radarFoldersHeader
        radarFoldersLoop
        radarLooseSection
    }
}
