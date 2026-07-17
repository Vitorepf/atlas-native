import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Compact/minimal Island — peel de AtlasTurnLiveActivity+Island.
// Trailing/Minimal → +IslandCompact+Trailing.swift

struct AtlasTurnIslandCompactLeading: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
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
