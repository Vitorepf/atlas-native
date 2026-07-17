import SwiftUI
import AtlasCore

// Surfaces filter/timeline — peel de LiveTimeline.
// Scroll → LiveTimeline+Scroll.swift
// Timeline → LiveTimeline+TimelineSurface.swift

extension LiveTimeline {
    @ViewBuilder
    var filterSilenceSurface: some View {
        if showsFilterChips {
            TimelineFilterChips(filter: $filter,
                                baseRows: baseRows,
                                reduceMotion: reduceMotion,
                                filterSilence: filterSilence)
                .accessibilityElement(children: .contain)
                .accessibilityLabel(LiveTimelineA11y.spokenFilterSilenceSurface(filter: filter,
                                                                                totalSteps: baseRows.count))
                .accessibilityIdentifier(A11yID.liveTimelineFilterSilence)
        }
    }
}
