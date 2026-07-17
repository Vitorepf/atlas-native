import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Progress branch — peel de AtlasTurnLiveActivity+IslandMinimal.

extension AtlasTurnIslandMinimal {
    @ViewBuilder
    var islandMinimalProgressBranch: some View {
        if let progress = context.state.progressLabel, !context.state.finished {
            islandMinimalProgress(progress)
        }
    }
}
