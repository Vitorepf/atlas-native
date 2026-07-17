import SwiftUI
import AtlasCore

// Hub conversation destinations — peel de RootView+DestinationsConversation.

extension RootView {
    @ViewBuilder
    func rootConversationHubRoutes(for route: Route) -> some View {
        switch route {
        case .new:
            rootConversationNewDestination
        case .conversas:
            rootConversationConversasDestination
        case .search:
            rootConversationSearchDestination
        default:
            EmptyView()
        }
    }
}
