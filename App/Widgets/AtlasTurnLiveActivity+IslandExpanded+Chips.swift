import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Island progress/queue chips — peel de AtlasTurnLiveActivity+IslandExpanded+Center.
// Queue → AtlasTurnLiveActivity+IslandExpanded+QueueChip.swift

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
                queueChip
            }
        }
    }
}
