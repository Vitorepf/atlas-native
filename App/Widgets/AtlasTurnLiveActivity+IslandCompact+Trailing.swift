import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Compact trailing — peel de IslandCompact.
// Minimal → AtlasTurnLiveActivity+IslandMinimal.swift
// Timer → AtlasTurnLiveActivity+IslandCompact+Timer.swift
// Progress → AtlasTurnLiveActivity+IslandCompact+TrailingProgress.swift
// Badge → AtlasTurnLiveActivity+IslandCompact+TrailingBadge.swift

struct AtlasTurnIslandCompactTrailing: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.finished || context.state.phaseBadge != nil || context.state.paused == true {
            finishedOrBadgeTrailing
        } else {
            progressOrQueueTrailing
        }
    }
}
