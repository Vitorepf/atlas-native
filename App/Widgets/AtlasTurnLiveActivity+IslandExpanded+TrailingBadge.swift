import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Finished/badge trailing — peel de IslandExpanded+Trailing.

extension AtlasTurnIslandTrailing {
    @ViewBuilder
    func finishedOrBadgeTrailing(context: ActivityViewContext<AtlasTurnAttributes>) -> some View {
        if context.state.finished {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Ink.healed).padding(.trailing, 6)
        } else if let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
                .padding(.trailing, 6)
                .accessibilityLabel(context.state.phaseTitle)
        }
    }
}
