import Foundation
import AtlasCore

/// Pack de partida da Home — presentation-only (sem dump de outros mundos).
/// Intenção free: o operador pode pedir qualquer coisa; o pack local anexa.
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
        var lines: [String] = [
            "Contexto Home (partida). Pack local da home; intenção do operador pode pedir outro mundo.",
        ]
        let threads = session.threads
        lines.append("Conversas conhecidas: \(threads.count).")
        let live = TurnPresence.shared.liveSessions
        if live.isEmpty {
            lines.append("Nenhuma sessão viva no hub agora.")
        } else {
            lines.append("Sessões vivas: \(live.count).")
            for s in live.prefix(5) {
                lines.append("- \(s.title) · \(s.phaseTitle)")
            }
        }
        let workspaces = session.workspaces
        if workspaces.isEmpty {
            lines.append("Nenhum workspace listado.")
        } else {
            lines.append("Workspaces: \(workspaces.prefix(8).map(\.name).joined(separator: ", ")).")
        }
        lines.append("Ausências: não invente contagens de frota/Arena sem a superfície correspondente.")
        return lines.joined(separator: "\n")
    }
}
