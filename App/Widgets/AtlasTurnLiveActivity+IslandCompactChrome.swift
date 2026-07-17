import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Compact chrome — peel de AtlasTurnLiveActivity+IslandCompactShell.

extension AtlasTurnLiveActivity {
    @ViewBuilder
    func islandCompactLeading(context: ActivityViewContext<AtlasTurnAttributes>) -> some View {
        AtlasTurnIslandCompactLeading(context: context)
    }

    @ViewBuilder
    func islandCompactTrailing(context: ActivityViewContext<AtlasTurnAttributes>) -> some View {
        AtlasTurnIslandCompactTrailing(context: context)
    }

    @ViewBuilder
    func islandMinimal(context: ActivityViewContext<AtlasTurnAttributes>) -> some View {
        AtlasTurnIslandMinimal(context: context)
    }
}
