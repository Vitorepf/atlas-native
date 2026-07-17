import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Phase badge compact — peel de IslandCompact TrailingBadge BadgePaused.

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var badgeTrailingChip: some View {
        if let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        }
    }
}
