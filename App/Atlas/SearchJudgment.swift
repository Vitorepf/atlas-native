import Foundation

// MARK: - Types

/// Exclusive Search screen face (WAVE-071).
enum SearchScreenFace: Equatable {
    case loading
    case offline
    case emptyRecent
    case emptyQuery
    case resultsRecent(Int)
    case resultsQuery(Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .offline: return "offline"
        case .emptyRecent: return "empty_recent"
        case .emptyQuery: return "empty_query"
        case .resultsRecent: return "results_recent"
        case .resultsQuery: return "results_query"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "carregando conversas"
        case .offline:
            return "offline"
        case .emptyRecent:
            return "sem recentes neste recorte"
        case .emptyQuery:
            return "nada com a consulta"
        case .resultsRecent(let n):
            return n == 1 ? "1 recente" : "\(n) recentes"
        case .resultsQuery(let n):
            return n == 1 ? "1 resultado" : "\(n) resultados"
        }
    }
}

// MARK: - Judgment

/// Pure search-screen grammar — face · spoken · pack.
enum SearchJudgment {

    static let screenHint = "busca local nas conversas já carregadas na sessão"
    static let backLabel = "voltar"
    static let backHint = "fecha a busca"
    static let clearLabel = "limpar busca"
    static let clearHint = "remove o texto e volta aos recentes"

    static func face(
        showsLoadingShell: Bool,
        showsNetworkFailure: Bool,
        isBrowsingRecent: Bool,
        recentCount: Int,
        resultCount: Int,
        trimmedQuery: String
    ) -> SearchScreenFace {
        if showsLoadingShell { return .loading }
        if showsNetworkFailure { return .offline }
        if isBrowsingRecent {
            if recentCount <= 0 { return .emptyRecent }
            return .resultsRecent(recentCount)
        }
        if resultCount <= 0 { return .emptyQuery }
        return .resultsQuery(resultCount)
    }

    static func spokenScreen(
        face: SearchScreenFace,
        trimmedQuery: String
    ) -> String {
        switch face {
        case .loading:
            return "busca, carregando conversas"
        case .offline:
            return "busca, offline"
        case .emptyRecent:
            return "busca, sem recentes neste recorte"
        case .emptyQuery:
            return "busca, nada com \(trimmedQuery)"
        case .resultsRecent(let n):
            return "busca, \(n) recente\(n == 1 ? "" : "s")"
        case .resultsQuery(let n):
            return "busca, \(n) resultado\(n == 1 ? "" : "s") para \(trimmedQuery)"
        }
    }

    static func packFacts(
        showsLoadingShell: Bool,
        showsNetworkFailure: Bool,
        isBrowsingRecent: Bool,
        recentCount: Int,
        resultCount: Int,
        trimmedQuery: String
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(
            showsLoadingShell: showsLoadingShell,
            showsNetworkFailure: showsNetworkFailure,
            isBrowsingRecent: isBrowsingRecent,
            recentCount: recentCount,
            resultCount: resultCount,
            trimmedQuery: trimmedQuery
        )
        facts.append("search_face: \(face.productWord)")
        if !trimmedQuery.isEmpty {
            facts.append("search_query: \(trimmedQuery)")
        }
        switch face {
        case .loading:
            absences.append("busca ainda carregando")
        case .offline:
            absences.append("busca offline")
        case .emptyRecent:
            absences.append("sem recentes neste recorte")
        case .emptyQuery:
            absences.append("consulta sem resultados")
        case .resultsRecent(let n):
            facts.append("search_recent_count: \(n)")
        case .resultsQuery(let n):
            facts.append("search_result_count: \(n)")
        }

        // WAVE-089: list organ pack (captions/rows/miss) — independent of screen face words.
        let list = SearchListJudgment.packFacts(
            isBrowsingRecent: isBrowsingRecent,
            recentCount: recentCount,
            resultCount: resultCount,
            trimmedQuery: trimmedQuery,
            screenIsBlocking: showsLoadingShell || showsNetworkFailure
        )
        facts.append(contentsOf: list.facts)
        absences.append(contentsOf: list.absences)
        return (facts, absences)
    }
}
