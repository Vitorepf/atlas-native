import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Center region — peel de AtlasTurnLiveActivity+IslandExpandedRegions.

extension AtlasTurnLiveActivity {
    @DynamicIslandExpandedContentBuilder
    func islandExpandedCenter(context: ActivityViewContext<AtlasTurnAttributes>) -> some DynamicIslandExpandedContent {
        DynamicIslandExpandedRegion(.center) {
            AtlasTurnIslandCenter(context: context)
        }
    }
}
