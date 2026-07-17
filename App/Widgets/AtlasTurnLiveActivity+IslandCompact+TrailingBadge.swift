import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Compact finished/badge — peel de IslandCompact+Trailing.

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var finishedOrBadgeTrailing: some View {
        if context.state.finished {
            Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
                .foregroundStyle(Ink.healed)
        } else if let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        } else if context.state.paused == true {
            Text("‖").font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }
}
