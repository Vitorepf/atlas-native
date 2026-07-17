import SwiftUI
import AtlasCore

// Surfaces filter/timeline — peel de LiveTimeline.
// Scroll → LiveTimeline+Scroll.swift
// Timeline → LiveTimeline+TimelineSurface.swift
// A11y → LiveTimeline+Surfaces+A11yBind.swift

extension LiveTimeline {
    @ViewBuilder
    var filterSilenceSurface: some View {
        if showsFilterChips {
            filterSilenceA11y(
                TimelineFilterChips(filter: $filter,
                                    baseRows: baseRows,
                                    reduceMotion: reduceMotion,
                                    filterSilence: filterSilence)
            )
        }
    }
}
