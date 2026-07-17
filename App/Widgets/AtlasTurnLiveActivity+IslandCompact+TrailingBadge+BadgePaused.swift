import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Badge/paused branch — peel de IslandCompact+TrailingBadge.
// Chip → AtlasTurnLiveActivity+IslandCompact+TrailingBadge+BadgePaused+Chip.swift

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var badgeOrPausedTrailing: some View {
        if context.state.phaseBadge != nil {
            badgeTrailingChip
        } else if context.state.paused == true {
            Text("‖").font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }
}
