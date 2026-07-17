import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Badge branch — peel de AtlasTurnLiveActivity+IslandMinimal.

extension AtlasTurnIslandMinimal {
    @ViewBuilder
    var islandMinimalBadgeBranch: some View {
        if let badge = context.state.phaseBadge, !context.state.finished {
            islandMinimalBadge(badge)
        }
    }
}
