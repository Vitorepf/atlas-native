import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Expanded Island trailing — peel de IslandExpanded+Center.

struct AtlasTurnIslandTrailing: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.finished {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Ink.healed).padding(.trailing, 6)
        } else if let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
                .padding(.trailing, 6)
                .accessibilityLabel(context.state.phaseTitle)
        } else {
            AtlasTurnWidgetTimer(
                startedAt: context.state.startedAt,
                paused: context.state.paused,
                pausedDisplay: context.state.pausedDisplay,
                fontSize: context.state.paused == true ? 12 : 13,
                frameWidth: 44,
                trailingPadding: 6
            )
        }
    }
}
