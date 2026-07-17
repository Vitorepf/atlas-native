import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Minimal island — peel de IslandCompact+Trailing.
// Badge → AtlasTurnLiveActivity+IslandMinimal+Badge.swift
// Progress → AtlasTurnLiveActivity+IslandMinimal+Progress.swift
// Symbol → AtlasTurnLiveActivity+IslandMinimal+Symbol.swift
// Body → AtlasTurnLiveActivity+IslandMinimal+Body.swift

struct AtlasTurnIslandMinimal: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        islandMinimalBody
    }
}
