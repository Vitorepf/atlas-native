import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Badge/paused branch — peel de IslandCompact+TrailingBadge.

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var badgeOrPausedTrailing: some View {
        if let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        } else if context.state.paused == true {
            Text("‖").font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }
}
