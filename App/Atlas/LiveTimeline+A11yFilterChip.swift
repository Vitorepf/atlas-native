import SwiftUI
import AtlasCore

// Filter chip spoken — peel de LiveTimeline+A11yFilter.

extension LiveTimelineA11y {
    static func spokenFilterChip(_ filter: TimelineReadFilter,
                                 count: Int,
                                 active: Bool,
                                 silent: Bool) -> String {
        var label = "filtrar timeline por \(filter.label), \(count) passo\(count == 1 ? "" : "s")"
        if active { label += ", selecionado" }
        if silent { label += ", nenhum passo neste filtro" }
        return label
    }
}
