import SwiftUI
import AtlasCore

/// Spoken labels da orquestra ao vivo — peel de LiveTimeline (cena 05 residual honesty).

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

    static func spokenRow(row: NarrativeRow, index: Int, total: Int, isCurrent: Bool) -> String {
        var parts = ["passo \(index + 1) de \(total)", row.title]
        if let detail = row.detail, !detail.isEmpty { parts.append(detail) }
        if let duration = row.durationMs {
            parts.append("duração \(humanDuration(duration))")
            if row.isP90 { parts.append("acima do p90") }
        }
        if isCurrent { parts.append("passo atual da orquestra") }
        return parts.joined(separator: ", ")
    }

    static func rowValue(index: Int, total: Int, isCurrent: Bool) -> String {
        isCurrent ? "passo \(index + 1) de \(total), em andamento" : "passo \(index + 1) de \(total)"
    }
}
