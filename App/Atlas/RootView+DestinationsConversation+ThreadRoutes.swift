import SwiftUI
import AtlasCore

// Thread/workspace conversation destinations — peel de RootView+DestinationsConversation.

extension RootView {
    @ViewBuilder
    func rootConversationThreadRoutes(for route: Route) -> some View {
        switch route {
        case .workspace(let key, let title):
            rootConversationWorkspaceDestination(key: key, title: title)
        case .thread(let id, let title):
            rootConversationThreadDestination(id: id, title: title)
        default:
            EmptyView()
        }
    }
}
