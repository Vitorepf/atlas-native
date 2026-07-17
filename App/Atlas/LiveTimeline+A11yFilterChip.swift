import SwiftUI
import AtlasCore

// Filter chip spoken — peel de LiveTimeline+A11yFilter.
// Suffix → LiveTimeline+A11yFilterChipSuffix.swift

extension LiveTimelineA11y {
    static func spokenFilterChip(_ filter: TimelineReadFilter,
                                 count: Int,
                                 active: Bool,
                                 silent: Bool) -> String {
        "filtrar timeline por \(filter.label), \(count) passo\(count == 1 ? "" : "s")"
            + spokenFilterChipSuffix(active: active, silent: silent)
    }
}
