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

        let live = TurnPresence.shared.liveSessions
        if live.isEmpty {
            facts.append("sessoes_vivas: 0")
        } else {
            facts.append("sessoes_vivas: \(live.count)")
            for s in live.prefix(5) {
                // WAVE-029: face product words (not raw phaseTitle lead).
                anchors.append(ConversationOccasionPack.liveAnchorLine(s))
            }
        }

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

        return AgenticOccasionPack(
            surface: "home",
            subject: "partida do operador",
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: .readChat
        ).render()
    }
}
