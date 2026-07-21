import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// WAVE-018 — Island compact leading + trailing (shared glanceFace).

struct AtlasTurnIslandCompactLeading: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.glanceFace == .multiSession {
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
        switch context.state.glanceFace {
        case .finished:
            Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
                .foregroundStyle(Ink.healed)
                .accessibilityLabel("concluído")
        case .paused:
            if let badge = context.state.phaseBadge {
                Text(badge)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Ink.alert)
            } else {
                Text("‖").font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Ink.ink2)
            }
        case .multiSession, .running:
            if let badge = context.state.phaseBadge {
                Text(badge)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Ink.alert)
            } else if context.state.queueLabel != nil, context.state.progressLabel == nil,
                      let queued = context.state.queueLabel {
                Text(queued)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Ink.gold)
                    .accessibilityLabel(queued)
            } else if let progress = context.state.progressLabel {
                Text(progress)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Ink.gold)
            } else if context.state.showsGlanceTimer {
                AtlasTurnWidgetTimer(
                    startedAt: context.state.startedAt,
                    paused: context.state.paused,
                    pausedDisplay: context.state.pausedDisplay,
                    fontSize: 12,
                    frameWidth: 40
                )
            }
        }
    }
}
