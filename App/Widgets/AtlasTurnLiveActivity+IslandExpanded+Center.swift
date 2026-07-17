import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Expanded Island center — peel de AtlasTurnLiveActivity+IslandExpanded.
// Trailing → +Trailing.swift

struct AtlasTurnIslandCenter: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(context.attributes.threadTitle)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink).lineLimit(1)
            Text(context.state.phaseTitle)
                .font(.system(size: 12, design: .serif)).italic()
                .foregroundStyle(Ink.ink2).lineLimit(1)
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
