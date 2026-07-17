import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Minimal island — peel de IslandCompact+Trailing.

struct AtlasTurnIslandMinimal: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if let badge = context.state.phaseBadge, !context.state.finished {
            Text(badge)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        } else if let progress = context.state.progressLabel, !context.state.finished {
            Text(progress)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(context.state.atlasColor)
        } else {
            Text(context.state.atlasSymbol).font(.system(size: 14, design: .serif)).foregroundStyle(context.state.atlasColor)
        }
    }
}
