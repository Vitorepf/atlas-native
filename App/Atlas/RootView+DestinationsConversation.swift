import SwiftUI
import AtlasCore

// Conversation destinations — peel de RootView+Destinations.
// Workspace → RootView+DestinationsConversation+Workspace.swift
// Thread → RootView+DestinationsConversation+Thread.swift
// New → RootView+DestinationsConversation+New.swift
// Conversas → RootView+DestinationsConversation+Conversas.swift
// Search → RootView+DestinationsConversation+Search.swift

extension RootView {
    @ViewBuilder
    func rootConversationDestination(for route: Route) -> some View {
        switch route {
        case .workspace(let key, let title):
            rootConversationWorkspaceDestination(key: key, title: title)
        case .thread(let id, let title):
            rootConversationThreadDestination(id: id, title: title)
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
