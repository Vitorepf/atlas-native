import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Progress branch — peel de IslandCompact+TrailingProgress.

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var progressLabelTrailing: some View {
        if let progress = context.state.progressLabel {
            Text(progress)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.gold)
        }
    }
}
