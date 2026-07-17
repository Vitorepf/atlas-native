import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Queue branch — peel de IslandCompact+TrailingProgress.

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var queueLabelTrailing: some View {
        if context.state.progressLabel == nil, let queued = context.state.queueLabel {
            Text(queued)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.gold)
                .accessibilityLabel(queued)
        }
    }
}
