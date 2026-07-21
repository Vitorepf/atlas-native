import SwiftUI
import AtlasCore

// Filter chip a11y — peel de LiveTimeline+FilterButton.

extension TimelineFilterChips {
    func filterChipA11y<Content: View>(
        _ content: Content,
        option: TimelineReadFilter,
        active: Bool,
        count: Int
    ) -> some View {
        content
            .accessibilityLabel(LiveTimelineA11y.spokenFilterChip(option,
                                                                  count: count,
                                                                  active: active,
                                                                  silent: active && filterSilence))
            .accessibilityHint(LiveTimelineA11y.spokenFilterHint())
            .accessibilityAddTraits(active ? .isSelected : [])
            .accessibilityIdentifier(A11yID.liveTimelineFilter(option.rawValue))
    }
}
