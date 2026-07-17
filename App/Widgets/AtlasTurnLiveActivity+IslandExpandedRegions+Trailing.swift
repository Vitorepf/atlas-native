import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Trailing region — peel de AtlasTurnLiveActivity+IslandExpandedRegions.

extension AtlasTurnLiveActivity {
    @DynamicIslandExpandedContentBuilder
    func islandExpandedTrailing(context: ActivityViewContext<AtlasTurnAttributes>) -> some DynamicIslandExpandedContent {
        DynamicIslandExpandedRegion(.trailing) {
            AtlasTurnIslandTrailing(context: context)
        }
    }
}
