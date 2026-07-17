import SwiftUI
import AtlasCore

/// Filtros e roteamento de conversas na home — peel de RootHomeSections.
/// Chips → RootHomeSections+Chips.swift
extension RootHomeSections {
    /// Conversas sem projeto (workspace nulo) — o modo "só conversar".
    var freeThreadCount: Int {
        session.threads.filter { $0.workspace == nil }.count
    }

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

    var homeConversationThreadCount: Int {
        switch homeWorkspaceFilter {
        case .some("__all"): return session.threads.count
        case .some(let key): return session.threads(inWorkspace: key).count
        case .none: return freeThreadCount
        }
    }

    var homeConversationCount: Int? {
        let n = homeConversationThreadCount
        return n > 0 ? n : nil
    }

    var auditDetail: String {
        let key = homeWorkspaceFilter ?? "livres"
        let n = homeConversationCount ?? 0
        return "auditoria · filtro \(key) · \(n) threads"
    }
}
