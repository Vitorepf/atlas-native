import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: Search judgment family fused

// MARK: - SearchJudgment

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
// MARK: - SearchListJudgment

// MARK: - Types

/// Exclusive search list/row editorial face (WAVE-089).
/// Screen face stays WAVE-071; this organ is list captions + rows + miss.
enum SearchListFace: Equatable {
    case silence
    case recent(Int)
    case results(Int)
    case miss

    var productWord: String {
        switch self {
        case .silence: return "silence"
        case .recent(let n): return "recent(\(n))"
        case .results(let n): return "results(\(n))"
        case .miss: return "miss"
        }
    }

    var spokenFace: String {
        switch self {
        case .silence:
            return "lista em silêncio"
        case .recent(let n):
            let noun = n == 1 ? "recente" : "recentes"
            return "\(n) \(noun)"
        case .results(let n):
            let noun = n == 1 ? "resultado" : "resultados"
            return "\(n) \(noun)"
        case .miss:
            return "nada com a consulta"
        }
    }
}

// MARK: - Judgment

/// Pure search-list grammar — list face · field · captions · row · miss · pack.
enum SearchListJudgment {

    static let openThreadHint = "abre a conversa"
    static let fieldPlaceholder = "Buscar conversas"

    // MARK: Face

    static func listFace(
        isBrowsingRecent: Bool,
        recentCount: Int,
        resultCount: Int,
        trimmedQuery: String,
        screenIsBlocking: Bool
    ) -> SearchListFace {
        if screenIsBlocking { return .silence }
        if isBrowsingRecent {
            if recentCount <= 0 { return .silence }
            return .recent(recentCount)
        }
        if trimmedQuery.isEmpty { return .silence }
        if resultCount <= 0 { return .miss }
        return .results(resultCount)
    }

    // MARK: Field / captions

    static func spokenField(query: String) -> String {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "buscar conversas" }
        return "buscar conversas, \(trimmed)"
    }

    static func spokenRecentCaption(count: Int) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        let loaded = count == 1 ? "carregada" : "carregadas"
        return "recentes, \(count) \(noun) \(loaded)"
    }

    static func spokenResultsCaption(count: Int, query: String) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        return "\(count) \(noun) com ‘\(query)’"
    }

    static func resultsCaptionText(count: Int) -> String {
        "\(count) resultado\(count == 1 ? "" : "s")"
    }

    // MARK: Miss

    static func missHeadline(query: String, loadedThreadCount: Int) -> String {
        if loadedThreadCount >= 100 {
            return "“Nada com ‘\(query)’ nas 100 conversas mais recentes.”"
        }
        return "“Nada com ‘\(query)’.”"
    }

    // MARK: Row

    static func spokenRow(
        title: String,
        messageCount: Int,
        isRunning: Bool,
        hasNewer: Bool
    ) -> String {
        var parts = [title, "\(messageCount) mensagens"]
        if isRunning {
            parts.append("executando")
        } else if hasNewer {
            parts.append("novo desde a última visita")
        }
        return parts.joined(separator: ", ")
    }

    @MainActor
    static func spokenRow(thread: AtlasAiThread) -> String {
        spokenRow(
            title: thread.title,
            messageCount: thread.messageCount,
            isRunning: WorkspaceThreadJudgment.isRunning(thread: thread),
            hasNewer: ConversationModel.hasNewerContent(thread)
        )
    }

    // MARK: Pack

    static func packFacts(
        isBrowsingRecent: Bool,
        recentCount: Int,
        resultCount: Int,
        trimmedQuery: String,
        screenIsBlocking: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = listFace(
            isBrowsingRecent: isBrowsingRecent,
            recentCount: recentCount,
            resultCount: resultCount,
            trimmedQuery: trimmedQuery,
            screenIsBlocking: screenIsBlocking
        )
        facts.append("search_list_face: \(face.productWord)")
        switch face {
        case .silence:
            absences.append("lista de busca em silêncio (shell loading/offline ou vazia)")
        case .recent(let n):
            facts.append("search_list_recent: \(n)")
        case .results(let n):
            facts.append("search_list_results: \(n)")
            if !trimmedQuery.isEmpty {
                facts.append("search_list_query: \(trimmedQuery)")
            }
        case .miss:
            absences.append("consulta sem resultados na lista carregada")
            if !trimmedQuery.isEmpty {
                facts.append("search_list_query: \(trimmedQuery)")
            }
        }
        return (facts, absences)
    }
}
// MARK: - SearchAskContext

// MARK: - Invite · empty

/// Pack de ocasião Search — WAVE-176 agentic door (pill + pack).
/// Casca only · SearchJudgment.packFacts sovereignty · never invents threads.
enum SearchAskContext {
    static let invite = "o que você procura?"

    static var emptySuggestions: [String] {
        [
            "o que há de recente?",
            "quais conversas estão vivas?",
            "abre a thread que pede atenção",
        ]
    }

    static func emptyPrompt(
        face: SearchScreenFace,
        trimmedQuery: String
    ) -> String {
        switch face {
        case .loading:
            return "busca ainda carregando conversas — o que você quer achar?"
        case .offline:
            return "busca offline — reconecte ou pergunte o que falta"
        case .emptyRecent:
            return "sem recentes neste recorte — o que você procura?"
        case .emptyQuery:
            return trimmedQuery.isEmpty
                ? invite
                : "nada com «\(trimmedQuery)» — refine ou pergunte o recorte"
        case .resultsRecent(let n):
            return n == 1
                ? "1 recente listado — o que você quer saber?"
                : "\(n) recentes listados — o que você quer saber?"
        case .resultsQuery(let n):
            return n == 1
                ? "1 resultado para «\(trimmedQuery)» — o que fazer?"
                : "\(n) resultados para «\(trimmedQuery)» — o que fazer?"
        }
    }

    // MARK: - Facts pack

    @MainActor
    static func facts(
        session: AtlasSession,
        showsLoadingShell: Bool,
        showsNetworkFailure: Bool,
        isBrowsingRecent: Bool,
        recentCount: Int,
        resultCount: Int,
        trimmedQuery: String
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        facts.append("tela: busca")
        anchors.append("surface: search")

        let screen = SearchJudgment.packFacts(
            showsLoadingShell: showsLoadingShell,
            showsNetworkFailure: showsNetworkFailure,
            isBrowsingRecent: isBrowsingRecent,
            recentCount: recentCount,
            resultCount: resultCount,
            trimmedQuery: trimmedQuery
        )
        facts.append(contentsOf: screen.facts)
        absences.append(contentsOf: screen.absences)

        // Live among listed threads (recents or results) — honesty only.
        let listed: [AtlasAiThread]
        if isBrowsingRecent {
            listed = Array(session.threads.prefix(12))
        } else if !trimmedQuery.isEmpty {
            let q = trimmedQuery.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            listed = session.threads.filter {
                $0.title.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                    .contains(q)
            }
        } else {
            listed = []
        }
        let ranked = WorkspaceThreadJudgment.rank(listed, remote: session.remoteLiveSessions)
        let liveAmong = ranked.filter { thread in
            session.remoteLiveSessions.contains { $0.threadId == ThreadID(thread.id) }
                || TurnPresence.shared.liveSessions.contains { $0.threadId == ThreadID(thread.id) }
        }
        if !liveAmong.isEmpty {
            facts.append("search_live_in_list: \(liveAmong.count)")
            for t in liveAmong.prefix(3) {
                anchors.append("live · \(t.title)")
            }
        } else if !listed.isEmpty {
            absences.append("nenhuma thread viva no recorte listado da busca")
        }

        let empty = ConversationEmptyJudgment.packFacts(
            prompt: emptyPrompt(
                face: SearchJudgment.face(
                    showsLoadingShell: showsLoadingShell,
                    showsNetworkFailure: showsNetworkFailure,
                    isBrowsingRecent: isBrowsingRecent,
                    recentCount: recentCount,
                    resultCount: resultCount,
                    trimmedQuery: trimmedQuery
                ),
                trimmedQuery: trimmedQuery
            ),
            suggestions: emptySuggestions,
            isHomePartida: false,
            hasWorkspaces: !session.workspaces.isEmpty
        )
        facts.append(contentsOf: empty.facts)
        absences.append(contentsOf: empty.absences)

        let partida = PartidaCanDoJudgment.search(
            liveInList: liveAmong.count,
            isOffline: showsNetworkFailure,
            isLoading: showsLoadingShell
        )
        absences.append(contentsOf: partida.absences)

        return AgenticOccasionPack(
            surface: "search",
            subject: trimmedQuery.isEmpty ? "busca · recentes" : "busca · «\(trimmedQuery)»",
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: partida.canDo
        ).render()
    }
}
