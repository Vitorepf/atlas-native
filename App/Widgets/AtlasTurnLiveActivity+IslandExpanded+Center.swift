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
            islandTitleStack
            progressQueueChips
        }
    }
}
