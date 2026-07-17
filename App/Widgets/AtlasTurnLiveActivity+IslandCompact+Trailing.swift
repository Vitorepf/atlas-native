import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Compact trailing — peel de IslandCompact.
// Minimal → AtlasTurnLiveActivity+IslandMinimal.swift
// Timer → AtlasTurnLiveActivity+IslandCompact+Timer.swift

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
        } else if let progress = context.state.progressLabel {
            Text(progress)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.gold)
        } else if let queued = context.state.queueLabel {
            Text(queued)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.gold)
                .accessibilityLabel(queued)
        } else {
            compactTimer
        }
    }
}
