import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Trailing region — peel de AtlasTurnLiveActivity+IslandCompactChrome.

extension AtlasTurnLiveActivity {
    @ViewBuilder
    func islandCompactTrailing(context: ActivityViewContext<AtlasTurnAttributes>) -> some View {
        AtlasTurnIslandCompactTrailing(context: context)
    }
}
