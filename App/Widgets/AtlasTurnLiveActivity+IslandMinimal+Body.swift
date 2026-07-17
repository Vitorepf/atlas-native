import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Minimal island branches — peel de AtlasTurnLiveActivity+IslandMinimal.

extension AtlasTurnIslandMinimal {
    @ViewBuilder
    var islandMinimalBody: some View {
        if context.state.phaseBadge != nil, !context.state.finished {
            islandMinimalBadgeBranch
        } else if context.state.progressLabel != nil, !context.state.finished {
            islandMinimalProgressBranch
        } else {
            islandMinimalSymbolBranch
        }
    }
}
