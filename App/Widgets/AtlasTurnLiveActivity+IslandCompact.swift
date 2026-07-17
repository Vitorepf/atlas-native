import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Compact/minimal Island — peel de AtlasTurnLiveActivity+Island.

struct AtlasTurnIslandCompactLeading: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.activeSessions > 1 {
            Text("\(context.state.atlasSymbol)\(context.state.activeSessions)")
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(context.state.atlasColor)
        } else {
            Text(context.state.atlasSymbol)
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(context.state.atlasColor)
        }
    }
}

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
        } else {
            Text(context.state.startedAt, style: .timer)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Ink.ink2).frame(width: 40)
        }
    }
}

struct AtlasTurnIslandMinimal: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if let badge = context.state.phaseBadge, !context.state.finished {
            Text(badge)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        } else if let progress = context.state.progressLabel, !context.state.finished {
            Text(progress)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(context.state.atlasColor)
        } else {
            Text(context.state.atlasSymbol).font(.system(size: 14, design: .serif)).foregroundStyle(context.state.atlasColor)
        }
    }
}
