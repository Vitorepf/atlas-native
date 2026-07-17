import SwiftUI
import AtlasCore

/// Home conversation route — peel de RootHomeSections+Conversation.
/// All → RootHomeSections+ConversationRoute+All.swift
/// Keyed → RootHomeSections+ConversationRoute+Keyed.swift

extension RootHomeSections {
    var homeConversationRoute: Route {
        switch homeWorkspaceFilter {
        case .some("__all"):
            return homeConversationAllRoute
        case .some(let key):
            return homeConversationKeyedRoute(key)
        case .none:
            return .conversas
        }
    }
}
