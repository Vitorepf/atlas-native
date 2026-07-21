import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive live narrative face (WAVE-044). Chrono order stays sacred.
enum LiveTimelineNarrativeFace: Equatable {
    case empty
    case live(Int)
    case filterSilence(filter: TimelineReadFilter, total: Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .live: return "live"
        case .filterSilence: return "filter_silence"
        }
    }

    var kicker: String {
        switch self {
        case .empty: return "Narrativa"
        case .live: return "Narrativa viva"
        case .filterSilence: return "Filtro em silêncio"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem passos de narrativa"
        case .live(let n):
            return n == 1 ? "1 passo na narrativa" : "\(n) passos na narrativa"
        case .filterSilence(let filter, let total):
            return "filtro \(filter.label) em silêncio, \(total) passos na obra completa"
        }
    }
}

// MARK: - Judgment

/// Pure narrative face grammar — never re-ranks rows.
enum LiveTimelineNarrativeJudgment {

    static func face(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> LiveTimelineNarrativeFace {
        if baseRows.isEmpty { return .empty }
        if filteredRows.isEmpty, filter != .all {
            return .filterSilence(filter: filter, total: baseRows.count)
        }
        return .live(filteredRows.count)
    }

    static func summaryLine(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> String {
        switch face(baseRows: baseRows, filteredRows: filteredRows, filter: filter) {
        case .empty:
            return "sem passos"
        case .live(let n):
            let intents = filteredRows.filter { $0.style == .intent }.count
            if filter == .all {
                return intents > 0
                    ? "\(n) passos · \(intents) intenção"
                    : "\(n) passos"
            }
            return "\(filter.label) · \(n) passos"
        case .filterSilence(let filter, let total):
            return "\(filter.label) · 0 de \(total)"
        }
    }

    static func spokenSection(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> String {
        let face = face(baseRows: baseRows, filteredRows: filteredRows, filter: filter)
        switch face {
        case .empty:
            return "narrativa da execução, \(face.spokenFace)"
        case .live:
            return "narrativa da execução, \(face.spokenFace), \(summaryLine(baseRows: baseRows, filteredRows: filteredRows, filter: filter))"
        case .filterSilence:
            return "narrativa da execução, \(face.spokenFace)"
        }
    }

    static func packFacts(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(baseRows: baseRows, filteredRows: filteredRows, filter: filter)
        facts.append("timeline_face: \(face.productWord)")
        facts.append("filter: \(filter.rawValue)")
        facts.append(summaryLine(baseRows: baseRows, filteredRows: filteredRows, filter: filter))
        if baseRows.isEmpty {
            absences.append("sem atividades publicadas na narrativa")
            return (facts, absences)
        }
        facts.append("base_steps: \(baseRows.count)")
        facts.append("filtered_steps: \(filteredRows.count)")
        let intents = baseRows.filter { $0.style == .intent }.count
        facts.append("intent_style: \(intents)")
        if case .filterSilence = face {
            absences.append("filtro \(filter.label) sem linhas — obra ainda tem \(baseRows.count) passos")
        }
        return (facts, absences)
    }

    /// WAVE-174: mid-thread pack from published activities (filter UI is local — open recorte).
    static func packFacts(from activities: [AtlasAgentActivity]) -> (facts: [String], absences: [String]) {
        let base = narrativeRows(from: activities)
        return packFacts(baseRows: base, filteredRows: base, filter: .all)
    }
}
