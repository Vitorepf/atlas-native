import SwiftUI
import AtlasCore

// WAVE-115 conversation route destinations

extension RootView {
    @ViewBuilder
    func rootCodeDestination(for route: Route) -> some View {
        switch route {
        case .code:
            AtlasCodeRadarView(client: session.client) { repo in
                path.append(Route.codeGraph(repo: repo))
            }
        case .codeGraph(let repo):
            // Troca de repo é in-place na própria tela (rápido).
            // Remount via path/.id era a experiência lenta.
            AtlasCodeView(client: session.client, repo: repo)
        default:
            EmptyView()
        }
    }
}

extension RootView {
    @ViewBuilder
    var rootConversationConversasDestination: some View {
        WorkspaceView(workspaceKey: nil, title: "Conversas", freeOnly: true)
    }
}

extension RootView {
    @ViewBuilder
    func rootConversationNewConversasRoutes(for route: Route) -> some View {
        switch route {
        case .new(let workspaceKey):
            rootConversationNewDestination(workspaceKey: workspaceKey)
        case .conversas:
            rootConversationConversasDestination
        default:
            EmptyView()
        }
    }
}

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

extension RootView {
    @ViewBuilder
    func rootConversationNewDestination(workspaceKey: String?) -> some View {
        if let workspaceKey {
            let name = session.workspaces.first(where: { $0.id == workspaceKey })?.name ?? workspaceKey
            let threadCount = session.threads(inWorkspace: workspaceKey).count
            ConversationView(
                client: session.client,
                threadId: nil,
                title: name,
                emptyPrompt: WorkspaceAskContext.invite(workspaceName: name),
                emptySuggestions: WorkspaceAskContext.emptySuggestions(
                    workspaceName: name,
                    threadCount: threadCount
                ),
                workspace: workspaceKey,
                turnFacts: { [session] _ in
                    WorkspaceAskContext.facts(session: session, workspaceKey: workspaceKey)
                }
            )
        } else {
            // Livre / hub: partida Home (não inventa workspace).
            ConversationView(
                client: session.client,
                threadId: nil,
                title: "Nova conversa",
                emptyPrompt: HomeAskContext.invite,
                emptySuggestions: HomeAskContext.emptySuggestions(
                    hasWorkspaces: !session.workspaces.isEmpty
                ),
                isHomePartida: true,
                workspace: nil,
                turnFacts: { [session] _ in
                    HomeAskContext.facts(session: session)
                }
            )
        }
    }
}

extension RootView {
    @ViewBuilder
    var rootConversationSearchDestination: some View {
        SearchView()
    }
}

extension RootView {
    @ViewBuilder
    func rootConversationThreadDestination(id: ThreadID, title: String) -> some View {
        // WAVE-029: mid-thread occasion = conversation pack (never Home partida).
        ConversationView(
            client: session.client,
            threadId: id,
            title: title,
            emptyPrompt: ConversationOccasionPack.invite,
            emptySuggestions: ConversationOccasionPack.emptySuggestions,
            turnFacts: { [session] _ in
                ConversationOccasionPack.facts(
                    session: session,
                    threadId: id,
                    title: title
                )
            }
        )
    }
}

extension RootView {
    @ViewBuilder
    func rootConversationThreadRoutes(for route: Route) -> some View {
        switch route {
        case .workspace(let key, let title):
            rootConversationWorkspaceDestination(key: key, title: title)
        case .thread(let id, let title):
            rootConversationThreadDestination(id: id, title: title)
        default:
            EmptyView()
        }
    }
}

extension RootView {
    @ViewBuilder
    func rootConversationWorkspaceDestination(key: String?, title: String) -> some View {
        WorkspaceView(workspaceKey: key, title: title)
    }
}

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

