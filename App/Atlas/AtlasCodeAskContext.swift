import Foundation
import AtlasCore

/// Pack de ocasião do Grafo/Código — presentation-only (WAVE-019).
/// Pílula e emptyPrompt falam o convite; turnFacts compila a ocasião + opcional ask server.
enum AtlasCodeAskContext {
    static let invite = "pergunte sobre este repositório"

    /// Sugestões canônicas Core (H6) — só o que o Atlas sabe responder.
    static var emptySuggestions: [String] { AtlasCodeAskSuggestions.all }

    /// Empty prompt da conversa: âncora de swipe se houver, senão convite do grafo.
    static func emptyPrompt(focusLegend: String?) -> String {
        if let focusLegend, !focusLegend.isEmpty {
            return "sobre \(focusLegend) — o que você quer saber?"
        }
        return invite
    }

    /// Alias DoD WAVE-019 (`facts` = occasion compiler).
    @MainActor
    static func facts(
        model: AtlasCodeModel,
        focusNode: AtlasCodeGraphNode?,
        focusLegend: String?,
        isAnchoring: Bool,
        serverAskFacts: String? = nil
    ) -> String {
        occasionFacts(
            model: model,
            focusNode: focusNode,
            focusLegend: focusLegend,
            isAnchoring: isAnchoring,
            serverAskFacts: serverAskFacts
        )
    }

    /// Pack da ocasião do grafo — surface · subject · anchors · facts · absences · can_do.
    /// Nunca inventa commits; dual-count e agent filter ausentes = absences explícitas.
    @MainActor
    static func occasionFacts(
        model: AtlasCodeModel,
        focusNode: AtlasCodeGraphNode?,
        focusLegend: String?,
        isAnchoring: Bool,
        serverAskFacts: String?
    ) -> String {
        var lines: [String] = [
            "surface: code.graph",
            "subject: repositório \(model.repo)",
        ]

        if let legend = focusLegend?.trimmingCharacters(in: .whitespacesAndNewlines), !legend.isEmpty {
            lines.append("anchor_legend: \(legend)")
        }
        if let node = focusNode {
            let short = String(node.hash.prefix(7))
            lines.append("anchor_commit: \(short)")
            if let message = node.message, !message.isEmpty {
                lines.append("anchor_subject: \(message)")
            }
            lines.append("anchor_state: \(model.state(for: node).rawValue)")
        } else if isAnchoring {
            lines.append("anchors: âncora H6 ativa (sem nó de swipe local)")
        }

        lines.append("repo: \(model.repo)")
        if let trunk = model.graph?.defaultBranch, !trunk.isEmpty {
            lines.append("trunk: \(trunk)")
        } else {
            lines.append("absences: trunk/default_branch não publicado neste load")
        }
        if let head = model.graph?.head, !head.isEmpty {
            lines.append("head: \(String(head.prefix(7)))")
        }
        if let trunkHead = model.graph?.trunkHead, !trunkHead.isEmpty {
            lines.append("trunk_head: \(String(trunkHead.prefix(7)))")
        }

        let nodes = model.graph?.nodes ?? []
        if !nodes.isEmpty {
            lines.append("commits_loaded: \(nodes.count)")
            let violating = nodes.filter { model.state(for: $0) == .violating }.count
            lines.append("sem_retorno_signals: \(violating)")
        } else {
            lines.append("absences: grafo sem nós (load vazio ou ainda carregando)")
        }

        switch model.phase {
        case .loading, .idle:
            lines.append("phase: loading")
        case .failed(let message):
            lines.append("phase: failed")
            if !message.isEmpty { lines.append("failure: \(message)") }
        case .loaded:
            lines.append("phase: loaded")
        }

        lines.append("absences: dual-count obra/branch vs issues não reconciliado na casca (Core §5 se faltar DTO)")
        lines.append("absences: filtro por agente não exposto no pack (sem DTO de filter)")
        lines.append("can_do: chat de leitura e julgamento; tool_permissions write não assumidos no mobile")
        lines.append("intent: julgamento soberano do grafo; pack nunca inventa merges, cures ou scores")

        if let server = serverAskFacts?.trimmingCharacters(in: .whitespacesAndNewlines), !server.isEmpty {
            lines.append("---")
            lines.append("server_ask_facts:")
            lines.append(server)
        }

        return lines.joined(separator: "\n")
    }
}
