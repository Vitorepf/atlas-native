import SwiftUI
import AtlasCore

// Autonomos/Arena domain destinations — peel de RootView+Destinations+DomainRoutes.

extension RootView {
    @ViewBuilder
    func rootAutonomosArenaDestination(for route: Route) -> some View {
        switch route {
        case .autonomos:
            AutonomosView()
        case .arena:
            AtlasArenaView(model: session.arena)
        default:
            EmptyView()
        }
    }
}
