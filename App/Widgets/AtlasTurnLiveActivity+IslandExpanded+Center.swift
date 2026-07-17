import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Expanded Island center — peel de AtlasTurnLiveActivity+IslandExpanded.
// Trailing → +Trailing.swift
// Chips → AtlasTurnLiveActivity+IslandExpanded+Chips.swift

struct AtlasTurnIslandCenter: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(context.attributes.threadTitle)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink).lineLimit(1)
            Text(context.state.phaseTitle)
                .font(.system(size: 12, design: .serif)).italic()
                .foregroundStyle(Ink.ink2).lineLimit(1)
            progressQueueChips
        }
    }
}
