import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Finished branch — peel de IslandCompact+TrailingBadge.

extension AtlasTurnIslandCompactTrailing {
    @ViewBuilder
    var finishedTrailing: some View {
        if context.state.finished {
            Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
                .foregroundStyle(Ink.healed)
        }
    }
}
