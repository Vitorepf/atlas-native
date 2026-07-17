import SwiftUI
import AtlasCore

// Conversation destinations — peel de RootView+Destinations.

extension RootView {
    @ViewBuilder
    func rootConversationDestination(for route: Route) -> some View {
        switch route {
        case .workspace(let key, let title):
            WorkspaceView(workspaceKey: key, title: title)
        case .thread(let id, let title):
            ConversationView(client: session.client, threadId: id, title: title)
        case .new:
            ConversationView(client: session.client, threadId: nil, title: "Nova conversa")
        case .conversas:
            WorkspaceView(workspaceKey: nil, title: "Conversas", freeOnly: true)
        case .search:
            SearchView()
        default:
            EmptyView()
        }
    }
}
