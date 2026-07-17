import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Finished/badge trailing — peel de IslandExpanded+Trailing.
// Finished → AtlasTurnLiveActivity+IslandExpanded+TrailingBadge+Finished.swift

extension AtlasTurnIslandTrailing {
    @ViewBuilder
    func finishedOrBadgeTrailing(context: ActivityViewContext<AtlasTurnAttributes>) -> some View {
        if context.state.finished {
            finishedTrailing()
        } else if let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
                .padding(.trailing, 6)
                .accessibilityLabel(context.state.phaseTitle)
        }
    }
}
