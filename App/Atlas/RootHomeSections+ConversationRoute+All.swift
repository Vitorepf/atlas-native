import SwiftUI
import AtlasCore

/// Home workspace-all route — peel de RootHomeSections+ConversationRoute.

extension RootHomeSections {
    var homeConversationAllRoute: Route {
        .workspace(key: nil, title: "Todas")
    }
}
