import SwiftUI
import AtlasCore

// Chip button — peel de LiveTimeline+Filters.
// Enum → LiveTimeline+FilterEnum.swift
// Chip label → LiveTimeline+FilterChip.swift

extension TimelineFilterChips {
    func filterChipButton(_ option: TimelineReadFilter, active: Bool, count: Int) -> some View {
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
