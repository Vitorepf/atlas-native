import SwiftUI
import AtlasCore

// Timeline surface — peel de LiveTimeline+Surfaces.

extension LiveTimeline {
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
