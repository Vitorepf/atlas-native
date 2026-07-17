import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Progress / queue trailing — peel de IslandCompact+Trailing.
// Progress → AtlasTurnLiveActivity+IslandCompact+TrailingProgress+Progress.swift
// Queue → AtlasTurnLiveActivity+IslandCompact+TrailingProgress+Queue.swift
// ProgressGate → AtlasTurnLiveActivity+IslandCompact+TrailingProgress+ProgressGate.swift

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var progressOrQueueTrailing: some View {
        if context.state.queueLabel != nil {
            queueLabelTrailing
        } else {
            progressLabelOrTimer
        }
    }
}
