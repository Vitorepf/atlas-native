import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Progress / queue trailing — peel de IslandCompact+Trailing.
// Progress → AtlasTurnLiveActivity+IslandCompact+TrailingProgress+Progress.swift
// Queue → AtlasTurnLiveActivity+IslandCompact+TrailingProgress+Queue.swift

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var progressOrQueueTrailing: some View {
        if context.state.progressLabel != nil {
            progressLabelTrailing
        } else if context.state.queueLabel != nil {
            queueLabelTrailing
        } else {
            compactTimer
        }
    }
}
