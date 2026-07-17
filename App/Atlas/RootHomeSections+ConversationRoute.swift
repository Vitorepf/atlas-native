import SwiftUI
import AtlasCore

/// Home conversation route — peel de RootHomeSections+Conversation.
/// All → RootHomeSections+ConversationRoute+All.swift

extension RootHomeSections {
    var homeConversationRoute: Route {
        switch homeWorkspaceFilter {
        case .some("__all"):
            return homeConversationAllRoute
        case .some(let key):
            let title = session.workspaces.first(where: { $0.id == key })?.name ?? "Workspace"
            return .workspace(key: key, title: title)
        case .none:
            return .conversas
        }
    }
}
