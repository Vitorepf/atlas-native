import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Expanded island regions — peel de AtlasTurnLiveActivity+IslandCompactShell.

extension AtlasTurnLiveActivity {
    @DynamicIslandExpandedContentBuilder
    func islandExpandedLayout(context: ActivityViewContext<AtlasTurnAttributes>) -> some DynamicIslandExpandedContent {
        DynamicIslandExpandedRegion(.leading) {
            AtlasTurnIslandLeading(context: context)
        }
        DynamicIslandExpandedRegion(.center) {
            AtlasTurnIslandCenter(context: context)
        }
        DynamicIslandExpandedRegion(.trailing) {
            AtlasTurnIslandTrailing(context: context)
        }
    }
}
