import SwiftUI
import AtlasCore

// Domain route destinations — peel de RootView+Destinations.
// AutonomosArena → RootView+Destinations+DomainRoutes+AutonomosArena.swift

extension RootView {
    @ViewBuilder
    func rootDomainDestination(for route: Route) -> some View {
        switch route {
        case .autonomos, .arena:
            rootAutonomosArenaDestination(for: route)
        case .code, .codeGraph(_):
            rootCodeDestination(for: route)
        default:
            EmptyView()
        }
    }
}
