import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Dynamic Island compact/minimal — peel de AtlasTurnLiveActivity+IslandExpandedShell.
// Expanded → AtlasTurnLiveActivity+IslandExpandedRegions.swift

extension AtlasTurnLiveActivity {
    @DynamicIslandContentBuilder
    func dynamicIslandCompact(context: ActivityViewContext<AtlasTurnAttributes>) -> DynamicIsland {
        DynamicIsland {
            islandExpandedLayout(context: context)
        } compactLeading: {
            islandCompactLeading(context: context)
        } compactTrailing: {
            islandCompactTrailing(context: context)
        } minimal: {
            islandMinimal(context: context)
        }
    }
}
