import SwiftUI
import AtlasCore

// navigationDestination — peel de RootView (régua ≤100).
// Code → RootView+DestinationsCode.swift
// Conversation → RootView+DestinationsConversation.swift

extension RootView {
    @ViewBuilder
    func rootDestination(for route: Route) -> some View {
        switch route {
        case .workspace(_, _), .thread(_, _), .new, .conversas, .search:
            rootConversationDestination(for: route)
        case .autonomos:
            AutonomosView()
        case .arena:
            AtlasArenaView(model: session.arena)
        case .code, .codeGraph(_):
            rootCodeDestination(for: route)
        }
    }
}
