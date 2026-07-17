import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Progress label branch — peel de AtlasTurnLiveActivity+IslandMinimal.

extension AtlasTurnIslandMinimal {
    func islandMinimalProgress(_ progress: String) -> some View {
        Text(progress)
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundStyle(context.state.atlasColor)
    }
}
