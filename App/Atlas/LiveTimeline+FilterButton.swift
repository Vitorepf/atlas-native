import SwiftUI
import AtlasCore

// Chip button — peel de LiveTimeline+Filters.
// Enum → LiveTimeline+FilterEnum.swift
// Chip label → LiveTimeline+FilterChip.swift
// A11y → LiveTimeline+FilterButton+A11y.swift

extension TimelineFilterChips {
    func filterChipButton(_ option: TimelineReadFilter, active: Bool, count: Int) -> some View {
        filterChipA11y(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                    filter = option
                }
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
