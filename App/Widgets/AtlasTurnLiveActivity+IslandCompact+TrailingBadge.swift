import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Compact finished/badge — peel de IslandCompact+Trailing.
// Finished → AtlasTurnLiveActivity+IslandCompact+TrailingBadge+Finished.swift
// BadgePaused → AtlasTurnLiveActivity+IslandCompact+TrailingBadge+BadgePaused.swift

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var finishedOrBadgeTrailing: some View {
        finishedTrailing
        badgeOrPausedTrailing
    }
}
