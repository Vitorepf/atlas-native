import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Timer fallback — peel de IslandCompact trailing.

extension AtlasTurnIslandCompactTrailing {
    var compactTimer: some View {
        AtlasTurnWidgetTimer(
            startedAt: context.state.startedAt,
            paused: context.state.paused,
            pausedDisplay: context.state.pausedDisplay,
            fontSize: 12,
            frameWidth: 40
        )
    }
}
