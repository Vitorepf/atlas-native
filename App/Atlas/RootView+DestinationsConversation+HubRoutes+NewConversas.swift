import SwiftUI
import AtlasCore

// New/conversas hub — peel de RootView+DestinationsConversation+HubRoutes.

extension RootView {
    @ViewBuilder
    func rootConversationNewConversasRoutes(for route: Route) -> some View {
        switch route {
        case .new:
            rootConversationNewDestination
        case .conversas:
            rootConversationConversasDestination
        default:
            EmptyView()
        }
    }
}
