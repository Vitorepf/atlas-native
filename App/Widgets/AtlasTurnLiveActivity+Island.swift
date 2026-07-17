import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Dynamic Island — composição ÚNICA com a API real do ActivityKit.
// (Reparo pós-merge Elite: os shells intermediários usavam atributos
// inexistentes — @DynamicIslandContentBuilder — e foram colapsados aqui.
// As folhas continuam nos arquivos leaf: IslandCompactChrome/Island*Leading…)

extension AtlasTurnLiveActivity {
    func dynamicIslandContent(context: ActivityViewContext<AtlasTurnAttributes>) -> DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                // O símbolo de estado (mesma folha do compact) abre a região.
                AtlasTurnIslandCompactLeading(context: context)
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
        .keylineTint(context.state.atlasColor)
        .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
    }
}
