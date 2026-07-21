import SwiftUI
import AtlasCore

// A11y — peel de LiveTimeline+NarrativeView.
// Pulse → LiveTimeline+NarrativePulse.swift

extension NarrativeRowView {
    var narrativeA11y: some View {
        narrativeBody
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(LiveTimelineA11y.spokenRow(row: row,
                                                           index: index,
                                                           total: total,
                                                           isCurrent: isCurrent))
            .accessibilityValue(LiveTimelineA11y.rowValue(index: index, total: total, isCurrent: isCurrent))
            .accessibilityAddTraits(currentTraits)
    }
}
