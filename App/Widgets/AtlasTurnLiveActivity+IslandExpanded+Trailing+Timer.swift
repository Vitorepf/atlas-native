import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Active timer trailing — peel de IslandExpanded+Trailing.

extension AtlasTurnIslandTrailing {
    var activeTimerTrailing: some View {
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
