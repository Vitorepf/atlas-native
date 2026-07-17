import SwiftUI
import AtlasCore

// Conversation destinations — peel de RootView+Destinations.
// Workspace → RootView+DestinationsConversation+Workspace.swift
// Thread → RootView+DestinationsConversation+Thread.swift
// New → RootView+DestinationsConversation+New.swift
// Conversas → RootView+DestinationsConversation+Conversas.swift
// Search → RootView+DestinationsConversation+Search.swift
// ThreadRoutes → RootView+DestinationsConversation+ThreadRoutes.swift
// HubRoutes → RootView+DestinationsConversation+HubRoutes.swift

extension RootView {
    @ViewBuilder
    func rootConversationDestination(for route: Route) -> some View {
        switch route {
        case .workspace(_, _), .thread(_, _):
            rootConversationThreadRoutes(for: route)
        case .new, .conversas, .search:
            rootConversationHubRoutes(for: route)
        default:
            EmptyView()
        }
    }
}
