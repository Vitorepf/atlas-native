import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Progress chip — peel de AtlasTurnLiveActivity+IslandExpanded+Chips.

extension AtlasTurnIslandCenter {
    @ViewBuilder
    var progressChip: some View {
        if let progress = context.state.progressLabel {
            Text(progress)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.gold)
        }
    }
}
