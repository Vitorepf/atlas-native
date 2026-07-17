import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Island progress/queue chips — peel de AtlasTurnLiveActivity+IslandExpanded+Center.

extension AtlasTurnIslandCenter {
    @ViewBuilder
    var progressQueueChips: some View {
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
