import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Expanded Island trailing — peel de IslandExpanded+Center.
// Badge → AtlasTurnLiveActivity+IslandExpanded+TrailingBadge.swift
// Timer → AtlasTurnLiveActivity+IslandExpanded+Trailing+Timer.swift

struct AtlasTurnIslandTrailing: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.finished || context.state.phaseBadge != nil {
            finishedOrBadgeTrailing(context: context)
        } else {
            activeTimerTrailing
        }
    }
}
