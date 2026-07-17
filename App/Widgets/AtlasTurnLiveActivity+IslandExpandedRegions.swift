import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Expanded island regions — peel de AtlasTurnLiveActivity+IslandCompactShell.
// Leading → AtlasTurnLiveActivity+IslandExpandedRegions+Leading.swift
// Center → AtlasTurnLiveActivity+IslandExpandedRegions+Center.swift
// Trailing → AtlasTurnLiveActivity+IslandExpandedRegions+Trailing.swift

extension AtlasTurnLiveActivity {
    @DynamicIslandExpandedContentBuilder
    func islandExpandedLayout(context: ActivityViewContext<AtlasTurnAttributes>) -> some DynamicIslandExpandedContent {
        islandExpandedLeading(context: context)
        islandExpandedCenter(context: context)
        islandExpandedTrailing(context: context)
    }
}
