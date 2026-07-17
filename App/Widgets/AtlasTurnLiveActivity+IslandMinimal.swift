import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Minimal island — peel de IslandCompact+Trailing.
// Badge → AtlasTurnLiveActivity+IslandMinimal+Badge.swift
// Progress → AtlasTurnLiveActivity+IslandMinimal+Progress.swift
// Symbol → AtlasTurnLiveActivity+IslandMinimal+Symbol.swift

struct AtlasTurnIslandMinimal: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if let badge = context.state.phaseBadge, !context.state.finished {
            islandMinimalBadge(badge)
        } else if let progress = context.state.progressLabel, !context.state.finished {
            islandMinimalProgress(progress)
        } else {
            islandMinimalSymbol
        }
    }
}
