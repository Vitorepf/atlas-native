import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Title stack — peel de AtlasTurnLiveActivity+IslandExpanded+Center.

extension AtlasTurnIslandCenter {
    var islandTitleStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(context.attributes.threadTitle)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink).lineLimit(1)
            Text(context.state.phaseTitle)
                .font(.system(size: 12, design: .serif)).italic()
                .foregroundStyle(Ink.ink2).lineLimit(1)
        }
    }
}
