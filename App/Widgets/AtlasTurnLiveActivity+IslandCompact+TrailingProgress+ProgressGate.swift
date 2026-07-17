import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Progress trailing gate — peel de IslandCompact TrailingProgress.

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var progressLabelOrTimer: some View {
        if context.state.progressLabel != nil {
            progressLabelTrailing
        } else {
            compactTimer
        }
    }
}
