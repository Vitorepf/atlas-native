import SwiftUI
import AtlasCore

// Filter chip loop — peel de LiveTimeline+Filters.

extension TimelineFilterChips {
    @ViewBuilder
    var filterChipLoop: some View {
        ForEach(TimelineReadFilter.allCases) { option in
            let active = option == filter
            let count = option.apply(to: baseRows).count
            filterChipButton(option, active: active, count: count)
        }
    }
}
