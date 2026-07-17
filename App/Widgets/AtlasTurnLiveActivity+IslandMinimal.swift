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
        if context.state.phaseBadge != nil, !context.state.finished {
            islandMinimalBadgeBranch
        } else if context.state.progressLabel != nil, !context.state.finished {
            islandMinimalProgressBranch
        } else {
            islandMinimalSymbolBranch
        }
    }
}
