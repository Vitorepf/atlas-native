import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// WAVE-018 — Dynamic Island composition + compact chrome (one grammar).

extension AtlasTurnLiveActivity {
    func dynamicIslandContent(context: ActivityViewContext<AtlasTurnAttributes>) -> DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                AtlasTurnIslandCompactLeading(context: context)
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
        .keylineTint(context.state.atlasColor)
        .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
    }
}
