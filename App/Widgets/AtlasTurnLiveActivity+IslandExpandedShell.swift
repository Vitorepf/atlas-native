import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Dynamic Island expanded regions — peel de AtlasTurnLiveActivity+Island.
// Compact → AtlasTurnLiveActivity+IslandCompactShell.swift

extension AtlasTurnLiveActivity {
    @DynamicIslandContentBuilder
    func dynamicIslandExpanded(context: ActivityViewContext<AtlasTurnAttributes>) -> DynamicIsland {
        dynamicIslandCompact(context: context)
    }
}
