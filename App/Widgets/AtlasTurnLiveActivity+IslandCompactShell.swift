import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Dynamic Island compact/minimal — peel de AtlasTurnLiveActivity+IslandExpandedShell.

extension AtlasTurnLiveActivity {
    @DynamicIslandContentBuilder
    func dynamicIslandCompact(context: ActivityViewContext<AtlasTurnAttributes>) -> DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                AtlasTurnIslandLeading(context: context)
            }
            DynamicIslandExpandedRegion(.center) {
                AtlasTurnIslandCenter(context: context)
            }
            DynamicIslandExpandedRegion(.trailing) {
                AtlasTurnIslandTrailing(context: context)
            }
        } compactLeading: {
            islandCompactLeading(context: context)
        } compactTrailing: {
            islandCompactTrailing(context: context)
        } minimal: {
            islandMinimal(context: context)
        }
    }
}
