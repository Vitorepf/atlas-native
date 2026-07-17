import SwiftUI
import AtlasCore

/// Spoken labels da orquestra ao vivo — peel de LiveTimeline (cena 05 residual honesty).
/// Row → LiveTimeline+A11yRow.swift

enum LiveTimelineA11y {
    static func spokenSectionLabel(stepCount: Int) -> String {
        "orquestra ao vivo, \(stepCount) passo\(stepCount == 1 ? "" : "s")"
    }

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

    static func spokenFilterSilenceSurface(filter: TimelineReadFilter, totalSteps: Int) -> String {
        "orquestra ao vivo, filtro \(filter.label), nenhum dos \(totalSteps) passos corresponde"
    }
}
