import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Symbol fallback — peel de AtlasTurnLiveActivity+IslandMinimal.

extension AtlasTurnIslandMinimal {
    var islandMinimalSymbol: some View {
        Text(context.state.atlasSymbol)
            .font(.system(size: 14, design: .serif))
            .foregroundStyle(context.state.atlasColor)
    }
}
