import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Symbol branch — peel de AtlasTurnLiveActivity+IslandCompact.

extension AtlasTurnIslandCompactLeading {
    @ViewBuilder
    var leadingSymbol: some View {
        if context.state.activeSessions > 1 {
            Text("\(context.state.atlasSymbol)\(context.state.activeSessions)")
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(context.state.atlasColor)
        } else {
            Text(context.state.atlasSymbol)
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(context.state.atlasColor)
        }
    }
}
