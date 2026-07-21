import Foundation
import AtlasCore

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
