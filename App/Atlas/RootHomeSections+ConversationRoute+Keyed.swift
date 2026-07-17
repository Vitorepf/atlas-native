import SwiftUI
import AtlasCore

/// Home keyed workspace route — peel de RootHomeSections+ConversationRoute.

extension RootHomeSections {
    func homeConversationKeyedRoute(_ key: String) -> Route {
        let title = session.workspaces.first(where: { $0.id == key })?.name ?? "Workspace"
        return .workspace(key: key, title: title)
    }
}
