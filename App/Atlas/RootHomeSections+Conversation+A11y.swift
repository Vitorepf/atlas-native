import AtlasCore
import SwiftUI

/// Spoken labels dos filtros CONVERSAS — peel de RootHomeSections+Conversation (CICLO C).
/// Contagem zero = «nenhuma conversa»; auditoria só quando o modo está ligado.
/// Entry → RootHomeSections+Conversation+A11yEntry.swift
/// Chip → RootHomeSections+Conversation+A11yChip.swift
/// Filter → RootHomeSections+Conversation+A11yFilter.swift

extension RootHomeSections {
    func filterChipsSpokenLabel() -> String {
        let active = activeWorkspaceFilterLabel()
        var parts = ["filtros de conversas", "\(active) selecionado"]
        let workspaceCount = session.workspaces.count
        if workspaceCount > 0 {
            parts.append("\(workspaceCount) workspace\(workspaceCount == 1 ? "" : "s")")
        }
        return parts.joined(separator: ", ")
    }
}
