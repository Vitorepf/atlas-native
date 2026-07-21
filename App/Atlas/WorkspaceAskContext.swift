import Foundation
import AtlasCore

/// Pack de ocasião do Workspace — presentation-only.
/// Nunca reutiliza dump da Home: o assunto é **este** workspace.
enum WorkspaceAskContext {
    static func invite(workspaceName: String) -> String {
        "Escreva sobre \(workspaceName)"
    }

    static func emptySuggestions(workspaceName: String, threadCount: Int) -> [String] {
        if threadCount > 0 {
            return [
                "O que está vivo em \(workspaceName)?",
                "Resume as conversas recentes deste workspace",
                "O que preciso julgar aqui?"
            ]
        }
        return [
            "Começa a primeira conversa em \(workspaceName)",
            "O que este workspace precisa agora?",
            "Como organizar o trabalho aqui?"
        ]
    }

    @MainActor
    static func facts(session: AtlasSession, workspaceKey: String) -> String {
        let name = session.workspaces.first(where: { $0.id == workspaceKey })?.name ?? workspaceKey
        let threads = session.threads(inWorkspace: workspaceKey)
        var lines: [String] = [
            "Contexto Workspace (ocasião). Pack local deste workspace; intenção do operador pode pedir outro mundo.",
            "Workspace: \(name) (chave \(workspaceKey)).",
            "Conversas neste workspace: \(threads.count).",
        ]
        if let full = session.workspaceFullPath(forKey: workspaceKey) {
            lines.append("Caminho conhecido: \(full).")
        } else {
            lines.append("Ausência: caminho completo do workspace não listado nas threads.")
        }
        for t in threads.prefix(6) {
            let shown = t.title.trimmingCharacters(in: .whitespacesAndNewlines)
            lines.append("- \(shown.isEmpty ? "sem título" : shown)")
        }
        if threads.isEmpty {
            lines.append("Ausência: ainda não há conversas neste workspace.")
        }
        let live = TurnPresence.shared.liveSessions
        if live.isEmpty {
            lines.append("Nenhuma sessão viva no hub agora.")
        } else {
            lines.append("Sessões vivas no hub (global): \(live.count) — não invente que são deste workspace.")
            for s in live.prefix(3) {
                lines.append("- \(s.title) · \(s.phaseTitle)")
            }
        }
        lines.append("Ausências: não invente grafo/Arena/frota; pack é só deste workspace.")
        return lines.joined(separator: "\n")
    }

    /// Nova conversa livre (sem workspace) — distinta da Home partida.
    static let freeInvite = "Escreva livremente"
}
