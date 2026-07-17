import SwiftUI
import AtlasCore

// navigationDestination — peel de RootView (régua ≤100).

extension RootView {
    @ViewBuilder
    func rootDestination(for route: Route) -> some View {
        switch route {
        case .workspace(let key, let title):
            WorkspaceView(workspaceKey: key, title: title)
        case .thread(let id, let title):
            ConversationView(client: session.client, threadId: id, title: title)
        case .new:
            ConversationView(client: session.client, threadId: nil, title: "Nova conversa")
        case .conversas:
            WorkspaceView(workspaceKey: nil, title: "Conversas", freeOnly: true)
        case .search:
            SearchView()
        case .autonomos:
            AutonomosView()
        case .arena:
            AtlasArenaView(model: session.arena)
        case .code:
            // A porta do domínio é o radar: a frota primeiro, o repo depois.
            AtlasCodeRadarView(client: session.client) { repo in
                path.append(Route.codeGraph(repo: repo))
            }
        case .codeGraph(let repo):
            AtlasCodeView(client: session.client, repo: repo)
        }
    }
}
