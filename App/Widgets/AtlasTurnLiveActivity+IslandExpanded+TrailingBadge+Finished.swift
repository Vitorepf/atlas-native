import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Finished trailing — peel de IslandExpanded TrailingBadge.

extension AtlasTurnIslandTrailing {
    @ViewBuilder
    func finishedTrailing() -> some View {
        Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(Ink.healed).padding(.trailing, 6)
    }
}
