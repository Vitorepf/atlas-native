import Foundation
import AtlasCore

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
