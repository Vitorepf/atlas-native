import SwiftUI
import AtlasCore

// Root code destinations — peel de RootView+Destinations.

extension RootView {
    @ViewBuilder
    func rootCodeDestination(for route: Route) -> some View {
        switch route {
        case .code:
            // A porta do domínio é o radar: a frota primeiro, o repo depois.
            AtlasCodeRadarView(client: session.client) { repo in
                path.append(Route.codeGraph(repo: repo))
            }
        case .codeGraph(let repo):
            AtlasCodeView(client: session.client, repo: repo)
        default:
            EmptyView()
        }
    }
}
