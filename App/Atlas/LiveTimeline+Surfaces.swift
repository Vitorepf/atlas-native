import SwiftUI
import AtlasCore

// Surfaces filter/timeline — peel de LiveTimeline.
// Scroll → LiveTimeline+Scroll.swift

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

    var timelineSurface: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsFilterChips {
                TimelineFilterChips(filter: $filter,
                                    baseRows: baseRows,
                                    reduceMotion: reduceMotion,
                                    filterSilence: false)
            }
            timelineScroll
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(LiveTimelineA11y.spokenSectionLabel(stepCount: rows.count))
        .accessibilityIdentifier(A11yID.liveTimeline)
    }
}
