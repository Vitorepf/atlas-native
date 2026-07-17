import SwiftUI
import AtlasCore

// Hub conversation destinations — peel de RootView+DestinationsConversation.
// NewConversas → RootView+DestinationsConversation+HubRoutes+NewConversas.swift

extension RootView {
    @ViewBuilder
    func rootConversationHubRoutes(for route: Route) -> some View {
        switch route {
        case .new, .conversas:
            rootConversationNewConversasRoutes(for: route)
        case .search:
            rootConversationSearchDestination
        default:
            EmptyView()
        }
    }
}
