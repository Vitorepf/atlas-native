import SwiftUI
import AtlasCore

// Chips de filtro da timeline — peel de LiveTimeline (régua anti-inchaço).
// Enum → LiveTimeline+FilterEnum.swift
// Chip → LiveTimeline+FilterChip.swift
// Button → LiveTimeline+FilterButton.swift

struct TimelineFilterChips: View {
    @Binding var filter: TimelineReadFilter
    var baseRows: [NarrativeRow]
    var reduceMotion: Bool = false
    var filterSilence: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            filterChipLoop
        }
        .padding(.leading, 20)
        .accessibilityIdentifier(A11yID.liveTimelineFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: filter)
    }
}
