import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Minimal region — peel de AtlasTurnLiveActivity+IslandCompactChrome.

extension AtlasTurnLiveActivity {
    @ViewBuilder
    func islandMinimal(context: ActivityViewContext<AtlasTurnAttributes>) -> some View {
        AtlasTurnIslandMinimal(context: context)
    }
}
