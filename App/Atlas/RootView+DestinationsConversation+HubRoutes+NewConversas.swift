import SwiftUI
import AtlasCore

// New/conversas hub — peel de RootView+DestinationsConversation+HubRoutes.

extension RootView {
    @ViewBuilder
    func rootConversationNewConversasRoutes(for route: Route) -> some View {
        switch route {
        case .new(let workspaceKey):
            rootConversationNewDestination(workspaceKey: workspaceKey)
        case .conversas:
            rootConversationConversasDestination
        default:
            EmptyView()
        }
    }
}
