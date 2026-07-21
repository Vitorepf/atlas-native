import ActivityKit
import AtlasCore
import SwiftUI
import WidgetKit

// WAVE-018/IDLE Island fused host

// --- AtlasTurnLiveActivity.swift ---
struct AtlasTurnLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AtlasTurnAttributes.self) { context in
            LockScreenView(context: context)
                .activityBackgroundTint(Ink.bg)
                .activitySystemActionForegroundColor(Ink.gold)
                .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
        } dynamicIsland: { context in
            dynamicIslandContent(context: context)
        }
    }
}

// --- AtlasTurnLiveActivity+Island.swift ---
extension AtlasTurnLiveActivity {
    func dynamicIslandContent(context: ActivityViewContext<AtlasTurnAttributes>) -> DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                AtlasTurnIslandCompactLeading(context: context)
            }
            DynamicIslandExpandedRegion(.center) {
                AtlasTurnIslandCenter(context: context)
            }
            DynamicIslandExpandedRegion(.trailing) {
                AtlasTurnIslandTrailing(context: context)
            }
        } compactLeading: {
            AtlasTurnIslandCompactLeading(context: context)
        } compactTrailing: {
            AtlasTurnIslandCompactTrailing(context: context)
        } minimal: {
            AtlasTurnIslandMinimal(context: context)
        }
        .keylineTint(context.state.atlasColor)
        .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
    }
}

// --- AtlasTurnLiveActivity+IslandCompact.swift ---
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

// --- AtlasTurnLiveActivity+IslandExpanded.swift ---
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

// --- AtlasTurnLiveActivity+IslandMinimal.swift ---
struct AtlasTurnIslandMinimal: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.glanceFace != .finished, let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        } else if context.state.glanceFace != .finished, let progress = context.state.progressLabel {
            Text(progress)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(context.state.atlasColor)
        } else {
            Text(context.state.atlasSymbol)
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(context.state.atlasColor)
        }
    }
}
