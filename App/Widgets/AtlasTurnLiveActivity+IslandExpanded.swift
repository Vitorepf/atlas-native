import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// WAVE-018 — Island expanded center + trailing.

struct AtlasTurnIslandCenter: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.threadTitle)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(Ink.ink).lineLimit(1)
                Text(context.state.phaseTitle)
                    .font(.system(size: 12, design: .serif)).italic()
                    .foregroundStyle(Ink.ink2).lineLimit(1)
            }
            if context.state.progressLabel != nil || context.state.queueLabel != nil {
                HStack(spacing: 6) {
                    if let progress = context.state.progressLabel {
                        Text(progress)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Ink.gold)
                    }
                    if let queued = context.state.queueLabel {
                        Text(queued)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(Ink.gold)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Ink.gold.opacity(0.18)))
                            .accessibilityLabel(queued)
                    }
                }
            }
        }
    }
}

struct AtlasTurnIslandTrailing: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        switch context.state.glanceFace {
        case .finished:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Ink.healed).padding(.trailing, 6)
                .accessibilityLabel("concluído")
        case .paused, .multiSession, .running:
            if let badge = context.state.phaseBadge {
                Text(badge)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(Ink.alert)
                    .padding(.trailing, 6)
                    .accessibilityLabel(context.state.phaseTitle)
            } else if context.state.showsGlanceTimer {
                AtlasTurnWidgetTimer(
                    startedAt: context.state.startedAt,
                    paused: context.state.paused,
                    pausedDisplay: context.state.pausedDisplay,
                    fontSize: context.state.paused == true ? 12 : 13,
                    frameWidth: 44,
                    trailingPadding: 6
                )
            }
        }
    }
}
