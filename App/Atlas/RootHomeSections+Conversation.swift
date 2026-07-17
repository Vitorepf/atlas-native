import SwiftUI
import AtlasCore

/// Filtros e roteamento de conversas na home — peel de RootHomeSections.
/// Chips → RootHomeSections+Chips.swift
/// Counts → RootHomeSections+ConversationCounts.swift
extension RootHomeSections {
    var homeConversationRoute: Route {
        switch homeWorkspaceFilter {
        case .some("__all"):
            return .workspace(key: nil, title: "Todas")
        case .some(let key):
            let title = session.workspaces.first(where: { $0.id == key })?.name ?? "Workspace"
            return .workspace(key: key, title: title)
        case .none:
            return .conversas
        }
    }

    var homeConversationLabel: String {
        switch homeWorkspaceFilter {
        case .some("__all"): return "Todas as conversas"
        case .some(let key): return session.workspaces.first(where: { $0.id == key })?.name ?? "Workspace"
        case .none: return "Conversas livres"
        }
    }
}
