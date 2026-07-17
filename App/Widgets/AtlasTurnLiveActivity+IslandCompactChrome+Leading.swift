import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Leading region — peel de AtlasTurnLiveActivity+IslandCompactChrome.

extension AtlasTurnLiveActivity {
    @ViewBuilder
    func islandCompactLeading(context: ActivityViewContext<AtlasTurnAttributes>) -> some View {
        AtlasTurnIslandCompactLeading(context: context)
    }
}
