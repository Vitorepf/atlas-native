import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Dynamic Island shell — peel de AtlasTurnLiveActivity+Island.
// Expanded → AtlasTurnLiveActivity+IslandExpandedShell.swift

extension AtlasTurnLiveActivity {
    @DynamicIslandContentBuilder
    func dynamicIslandContent(context: ActivityViewContext<AtlasTurnAttributes>) -> DynamicIsland {
        dynamicIslandExpanded(context: context)
            .keylineTint(context.state.atlasColor)
            .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
    }
}
