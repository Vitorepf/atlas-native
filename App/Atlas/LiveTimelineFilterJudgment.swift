import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive timeline read-filter face (WAVE-075) — chrono order sacred.
enum LiveTimelineFilterFace: Equatable {
    /// No filter applied (all).
    case open
    /// Filter selected and has matching steps.
    case active
    /// Filter selected but zero matching steps (silence surface).
    case silent

    var productWord: String {
        switch self {
        case .open: return "open"
        case .active: return "active"
        case .silent: return "silent"
        }
    }

    var spokenFace: String {
        switch self {
        case .open: return "filtro aberto"
        case .active: return "filtro ativo"
        case .silent: return "filtro sem passos"
        }
    }
}

// MARK: - Judgment

/// Pure timeline read-filter grammar — face · spoken · pack.
/// Does **not** reorder narrative (chrono sagrado · WAVE-042/044).
enum LiveTimelineFilterJudgment {

    static let filterHint = "altera quais passos da orquestra são exibidos"

    static func face(
        filter: TimelineReadFilter,
        matchCount: Int,
        isActive: Bool
    ) -> LiveTimelineFilterFace {
        if !isActive || filter == .all {
            return .open
        }
        if matchCount <= 0 { return .silent }
        return .active
    }

    static func spokenSectionLabel(stepCount: Int) -> String {
        "orquestra ao vivo, \(stepCount) passo\(stepCount == 1 ? "" : "s")"
    }

    static func spokenFilterChip(
        filter: TimelineReadFilter,
        count: Int,
        active: Bool,
        silent: Bool
    ) -> String {
        "filtrar timeline por \(filter.label), \(count) passo\(count == 1 ? "" : "s")"
            + spokenFilterChipSuffix(active: active, silent: silent)
    }

    static func spokenFilterChipSuffix(active: Bool, silent: Bool) -> String {
        var suffix = ""
        if active { suffix += ", selecionado" }
        if silent { suffix += ", nenhum passo neste filtro" }
        return suffix
    }

    static func spokenFilterSilenceSurface(
        filter: TimelineReadFilter,
        totalSteps: Int
    ) -> String {
        "orquestra ao vivo, filtro \(filter.label), nenhum dos \(totalSteps) passos corresponde"
    }

    static func spokenRow(
        row: NarrativeRow,
        index: Int,
        total: Int,
        isCurrent: Bool
    ) -> String {
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
        isCurrent
            ? "passo \(index + 1) de \(total), em andamento"
            : "passo \(index + 1) de \(total)"
    }

    static func packFacts(
        filter: TimelineReadFilter,
        matchCount: Int,
        totalSteps: Int,
        isActive: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(filter: filter, matchCount: matchCount, isActive: isActive)
        facts.append("timeline_filter_face: \(face.productWord)")
        facts.append("timeline_filter: \(filter.rawValue)")
        facts.append("timeline_filter_matches: \(matchCount)")
        facts.append("timeline_steps_total: \(totalSteps)")
        if face == .silent {
            absences.append("filtro sem passos correspondentes")
        }
        return (facts, absences)
    }
}
