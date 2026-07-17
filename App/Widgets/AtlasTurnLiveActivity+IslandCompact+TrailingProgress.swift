import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Progress / queue trailing — peel de IslandCompact+Trailing.

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var progressOrQueueTrailing: some View {
        if let progress = context.state.progressLabel {
            Text(progress)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.gold)
        } else if let queued = context.state.queueLabel {
            Text(queued)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.gold)
                .accessibilityLabel(queued)
        } else {
            compactTimer
        }
    }
}
