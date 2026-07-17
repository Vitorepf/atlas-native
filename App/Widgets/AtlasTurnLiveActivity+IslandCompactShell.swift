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
            AtlasTurnIslandCompactLeading(context: context)
        } compactTrailing: {
            AtlasTurnIslandCompactTrailing(context: context)
        } minimal: {
            AtlasTurnIslandMinimal(context: context)
        }
    }
}
