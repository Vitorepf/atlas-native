import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Dynamic Island expanded — peel de AtlasTurnLiveActivity+Island.

extension AtlasTurnLiveActivity {
    @DynamicIslandContentBuilder
    func dynamicIslandContent(context: ActivityViewContext<AtlasTurnAttributes>) -> DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                AtlasTurnIslandLeading(context: context)
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

private struct AtlasTurnIslandLeading: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        VStack(spacing: 2) {
            Text("✦")
                .font(.system(size: 24, design: .serif))
                .foregroundStyle(context.state.atlasColor)
            if context.state.activeSessions > 1 {
                Text("× \(context.state.activeSessions)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Ink.ink2)
            }
        }
        .padding(.leading, 6)
    }
}

private struct AtlasTurnIslandCenter: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(context.attributes.threadTitle)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink).lineLimit(1)
            Text(context.state.phaseTitle)
                .font(.system(size: 12, design: .serif)).italic()
                .foregroundStyle(Ink.ink2).lineLimit(1)
            if let progress = context.state.progressLabel {
                Text(progress)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Ink.gold)
            }
        }
    }
}

private struct AtlasTurnIslandTrailing: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.finished {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Ink.healed).padding(.trailing, 6)
        } else if let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
                .padding(.trailing, 6)
        } else if context.state.paused == true {
            Text("‖ \(context.state.pausedDisplay ?? "—")")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Ink.ink2).padding(.trailing, 6)
        } else {
            Text(context.state.startedAt, style: .timer)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(Ink.ink2)
                .frame(width: 44).padding(.trailing, 6)
        }
    }
}
