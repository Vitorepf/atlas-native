import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Expanded Island trailing — peel de IslandExpanded+Center.
// Badge → AtlasTurnLiveActivity+IslandExpanded+TrailingBadge.swift

struct AtlasTurnIslandTrailing: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.finished || context.state.phaseBadge != nil {
            finishedOrBadgeTrailing(context: context)
        } else {
            AtlasTurnWidgetTimer(
                startedAt: context.state.startedAt,
                paused: context.state.paused,
                pausedDisplay: context.state.pausedDisplay,
                fontSize: context.state.paused == true ? 12 : 13,
                frameWidth: 44,
                trailingPadding: 6
            )
        }
    }
}
