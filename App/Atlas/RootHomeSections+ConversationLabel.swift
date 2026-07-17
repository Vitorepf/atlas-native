import SwiftUI
import AtlasCore

/// Home conversation label — peel de RootHomeSections+Conversation.

extension RootHomeSections {
    var homeConversationLabel: String {
        switch homeWorkspaceFilter {
        case .some("__all"): return "Todas as conversas"
        case .some(let key): return session.workspaces.first(where: { $0.id == key })?.name ?? "Workspace"
        case .none: return "Conversas livres"
        }
    }
}
