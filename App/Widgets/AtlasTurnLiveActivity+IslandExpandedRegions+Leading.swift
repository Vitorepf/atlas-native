import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Leading region — peel de AtlasTurnLiveActivity+IslandExpandedRegions.

extension AtlasTurnLiveActivity {
    @DynamicIslandExpandedContentBuilder
    func islandExpandedLeading(context: ActivityViewContext<AtlasTurnAttributes>) -> some DynamicIslandExpandedContent {
        DynamicIslandExpandedRegion(.leading) {
            AtlasTurnIslandLeading(context: context)
        }
    }
}
