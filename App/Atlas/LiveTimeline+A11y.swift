import AtlasCore
import SwiftUI

// Cycle 025 fuse → LiveTimeline+A11y.swift

enum LiveTimelineA11y {
    static func spokenSectionLabel(stepCount: Int) -> String {
        "orquestra ao vivo, \(stepCount) passo\(stepCount == 1 ? "" : "s")"
    }
}

extension LiveTimelineA11y {
    static func spokenFilterChip(_ filter: TimelineReadFilter,
                                 count: Int,
                                 active: Bool,
                                 silent: Bool) -> String {
        "filtrar timeline por \(filter.label), \(count) passo\(count == 1 ? "" : "s")"
            + spokenFilterChipSuffix(active: active, silent: silent)
    }
}

extension LiveTimelineA11y {
    static func spokenFilterChipSuffix(active: Bool, silent: Bool) -> String {
        var suffix = ""
        if active { suffix += ", selecionado" }
        if silent { suffix += ", nenhum passo neste filtro" }
        return suffix
    }
}

extension LiveTimelineA11y {
    static func spokenFilterHint() -> String {
        "altera quais passos da orquestra são exibidos"
    }
}

extension LiveTimelineA11y {
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
}

extension LiveTimelineA11y {
    static func rowValue(index: Int, total: Int, isCurrent: Bool) -> String {
        isCurrent ? "passo \(index + 1) de \(total), em andamento" : "passo \(index + 1) de \(total)"
    }
}

extension LiveTimelineA11y {
    static func spokenFilterSilenceSurface(filter: TimelineReadFilter, totalSteps: Int) -> String {
        "orquestra ao vivo, filtro \(filter.label), nenhum dos \(totalSteps) passos corresponde"
    }
}
