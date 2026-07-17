import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Queue chip — peel de IslandExpanded+Chips.

extension AtlasTurnIslandCenter {
    @ViewBuilder
    var queueChip: some View {
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
