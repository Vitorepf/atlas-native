import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Expanded Island regions — peel de AtlasTurnLiveActivity+Island.
// Center/Trailing → AtlasTurnLiveActivity+IslandExpanded+Center.swift

struct AtlasTurnIslandLeading: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        VStack(spacing: 2) {
            Text("✦")
                .font(.system(size: 24, design: .serif))
                .foregroundStyle(context.state.atlasColor)
            if context.state.activeSessions > 1 {
                Text("× \(context.state.activeSessions)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Ink.ink2)
            }
        }
        .padding(.leading, 6)
    }
}
