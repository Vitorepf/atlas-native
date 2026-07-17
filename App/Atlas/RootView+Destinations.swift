import SwiftUI
import AtlasCore

// navigationDestination — peel de RootView (régua ≤100).
// Code → RootView+DestinationsCode.swift
// Conversation → RootView+DestinationsConversation.swift
// ConversationRoutes → RootView+Destinations+ConversationRoutes.swift
// DomainRoutes → RootView+Destinations+DomainRoutes.swift

extension RootView {
    @ViewBuilder
    func rootDestination(for route: Route) -> some View {
        switch route {
        case .workspace(_, _), .thread(_, _), .new, .conversas, .search:
            rootConversationRoutes(for: route)
        case .autonomos, .arena, .code, .codeGraph(_):
            rootDomainDestination(for: route)
        }
    }
}
