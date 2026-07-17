import SwiftUI
import AtlasCore

// Chip button — peel de LiveTimeline+Filters.
// Enum → LiveTimeline+FilterEnum.swift
// Chip label → LiveTimeline+FilterChip.swift
// A11y → LiveTimeline+FilterButton+A11y.swift
// Action → LiveTimeline+FilterButton+Action.swift

extension TimelineFilterChips {
    func filterChipButton(_ option: TimelineReadFilter, active: Bool, count: Int) -> some View {
        filterChipA11y(
            Button {
                filterChipAction(option)
            } label: {
                chipLabel(option, active: active)
            }
            .buttonStyle(.plain),
            option: option,
            active: active,
            count: count
        )
    }
}
