import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Island progress/queue chips — peel de AtlasTurnLiveActivity+IslandExpanded+Center.
// Progress → AtlasTurnLiveActivity+IslandExpanded+ProgressChip.swift
// Queue → AtlasTurnLiveActivity+IslandExpanded+QueueChip.swift

extension AtlasTurnIslandCenter {
    @ViewBuilder
    var progressQueueChips: some View {
        if context.state.progressLabel != nil || context.state.queueLabel != nil {
            HStack(spacing: 6) {
                progressChip
                queueChip
            }
        }
    }
}
