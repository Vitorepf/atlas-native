import Foundation
import AtlasCore

/// Pack de partida da Home — WAVE-020 grammar (surface · subject · anchors · facts · absences · can_do).
enum HomeAskContext {
    static let invite = "Escreva ao Atlas"

    static func emptySuggestions(hasWorkspaces: Bool) -> [String] {
        if hasWorkspaces {
            return [
                "O que está vivo agora?",
                "Abre o grafo do atlas-native",
                "Como está a Arena?"
            ]
        }
        return [
            "O que está vivo agora?",
            "Começa uma conversa livre",
            "O que preciso julgar hoje?"
        ]
    }

    @MainActor
    static func facts(session: AtlasSession) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        let threads = session.threads
        facts.append("conversas_conhecidas: \(threads.count)")

        // WAVE-064: live anchors follow LiveNow attention rank (not wire order).
        let livePack = LiveNowJudgment.packLiveAnchors(
            local: TurnPresence.shared.liveSessions,
            remote: session.remoteLiveSessions,
            limit: 5
        )
        facts.append(contentsOf: livePack.facts)
        anchors.append(contentsOf: livePack.anchors)
        absences.append(contentsOf: livePack.absences)

        let workspaces = session.workspaces
        if workspaces.isEmpty {
            absences.append("nenhum workspace listado")
        } else {
            facts.append("workspaces: \(workspaces.prefix(8).map(\.name).joined(separator: ", "))")
        }

        absences.append("não invente contagens de frota/Arena sem a superfície correspondente")

        // WAVE-047: ops door attention only from published Autônomos/Arena signals.
        let ops = HomeOpsJudgment.packFacts(session: session)
        facts.append(contentsOf: ops.facts)
        absences.append(contentsOf: ops.absences)

        // WAVE-084: empty editorial face for Home partida (catalog honesty).
        let empty = ConversationEmptyJudgment.packFacts(
            prompt: invite,
            suggestions: emptySuggestions(hasWorkspaces: !workspaces.isEmpty),
            isHomePartida: true,
            hasWorkspaces: !workspaces.isEmpty
        )
        facts.append(contentsOf: empty.facts)
        absences.append(contentsOf: empty.absences)

        // WAVE-158: can_do matrix — never bare readChat hardcode; no stop invent.
        let liveCount = LiveNowJudgment.rank(
            local: TurnPresence.shared.liveSessions,
            remote: session.remoteLiveSessions
        ).count
        let autonomosFace = HomeOpsJudgment.autonomosFace(model: session.autonomos)
        let partida = PartidaCanDoJudgment.home(
            autonomosFace: autonomosFace,
            liveCount: liveCount
        )
        absences.append(contentsOf: partida.absences)

        return AgenticOccasionPack(
            surface: "home",
            subject: "partida do operador",
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: partida.canDo
        ).render()
    }
}
