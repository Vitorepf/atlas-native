import SwiftUI
import AtlasCore

// Chips de filtro da timeline — peel de LiveTimeline (régua anti-inchaço).
// Enum → LiveTimeline+FilterEnum.swift
// Chip → LiveTimeline+FilterChip.swift

struct TimelineFilterChips: View {
    @Binding var filter: TimelineReadFilter
    var baseRows: [NarrativeRow]
    var reduceMotion: Bool = false
    var filterSilence: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(TimelineReadFilter.allCases) { option in
                let active = option == filter
                let count = option.apply(to: baseRows).count
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                        filter = option
                    }
                } label: {
                    chipLabel(option, active: active)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(LiveTimelineA11y.spokenFilterChip(option,
                                                                      count: count,
                                                                      active: active,
                                                                      silent: active && filterSilence))
                .accessibilityHint(LiveTimelineA11y.spokenFilterHint())
                .accessibilityAddTraits(active ? .isSelected : [])
                .accessibilityIdentifier(A11yID.liveTimelineFilter(option.rawValue))
            }
        }
        .padding(.leading, 20)
        .accessibilityIdentifier(A11yID.liveTimelineFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: filter)
    }
}
