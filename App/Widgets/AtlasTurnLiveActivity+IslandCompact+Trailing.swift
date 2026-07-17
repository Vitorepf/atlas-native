import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Compact trailing — peel de IslandCompact.
// Minimal → AtlasTurnLiveActivity+IslandMinimal.swift
// Timer → AtlasTurnLiveActivity+IslandCompact+Timer.swift
// Progress → AtlasTurnLiveActivity+IslandCompact+TrailingProgress.swift

struct AtlasTurnIslandCompactTrailing: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.finished {
            Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
                .foregroundStyle(Ink.healed)
        } else if let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        } else if context.state.paused == true {
            Text("‖").font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        } else {
            progressOrQueueTrailing
        }
    }
}
