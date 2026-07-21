import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// WAVE-018 — Island minimal (face-aware, no false progress after finished).

struct AtlasTurnIslandMinimal: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.glanceFace != .finished, let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        } else if context.state.glanceFace != .finished, let progress = context.state.progressLabel {
            Text(progress)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(context.state.atlasColor)
        } else {
            Text(context.state.atlasSymbol)
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(context.state.atlasColor)
        }
    }
}
