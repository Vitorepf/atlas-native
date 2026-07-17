import AtlasCore
import SwiftUI

/// Spoken labels dos filtros CONVERSAS — peel de RootHomeSections+Conversation (CICLO C).
/// Contagem zero = «nenhuma conversa»; auditoria só quando o modo está ligado.

extension RootHomeSections {
    func activeWorkspaceFilterLabel() -> String {
        switch homeWorkspaceFilter {
        case .none: return "Livres"
        case .some("__all"): return "Todas"
        case .some(let key):
            return session.workspaces.first(where: { $0.id == key })?.name ?? "Workspace"
        }
    }

    func filterChipsSpokenLabel() -> String {
        let active = activeWorkspaceFilterLabel()
        var parts = ["filtros de conversas", "\(active) selecionado"]
        let workspaceCount = session.workspaces.count
        if workspaceCount > 0 {
            parts.append("\(workspaceCount) workspace\(workspaceCount == 1 ? "" : "s")")
        }
        return parts.joined(separator: ", ")
    }

    func filterChipSpokenLabel(_ label: String, active: Bool) -> String {
        active ? "filtro \(label), selecionado" : "filtro \(label)"
    }

    func conversasEntrySpokenLabel() -> String {
        var parts = [homeConversationLabel]
        let n = homeConversationThreadCount
        if n == 0 {
            parts.append("nenhuma conversa")
        } else {
            parts.append("\(n) conversa\(n == 1 ? "" : "s")")
        }
        if session.auditModeEnabled {
            parts.append(auditDetail)
        }
        return parts.joined(separator: ", ")
    }
}
