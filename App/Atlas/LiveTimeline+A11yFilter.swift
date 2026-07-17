import SwiftUI
import AtlasCore

// Filter chip spoken — peel de LiveTimeline+A11y.
// Section → LiveTimeline+A11y.swift · Row → +A11yRow.swift · Silence → +A11ySilence.swift

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

    static func spokenFilterHint() -> String {
        "altera quais passos da orquestra são exibidos"
    }
}
