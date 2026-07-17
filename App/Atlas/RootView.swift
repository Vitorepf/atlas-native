import SwiftUI
import AtlasCore

// Home Workspaces-primeiro (estilo Cursor, tema Atlas): masthead Fraunces, lista
// de repos reais (campo `workspace` das threads) + "Todas" + "Adicionar". Entrar
// num workspace abre suas conversas com filtro de área.
struct RootView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State var path = NavigationPath()
    @State var codeHub: AtlasCodeHubModel?
    @State private var nightly = NightlyProposalController.shared
    @State private var homeWorkspaceFilter: String?

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                AtlasTheme.bg.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    topBar
                        .padding(.horizontal, AtlasTheme.Space.screen)
                        .padding(.top, 4)
                        .padding(.bottom, 14)

                    RootHomeSections(
                        reduceMotion: reduceMotion,
                        homeWorkspaceFilter: $homeWorkspaceFilter,
                        onNavigate: { path.append($0) },
                        onOpenThread: { id, title in path.append(Route.thread(id: id, title: title)) }
                    )
                }

                inputBar
            }
            .navigationBarHidden(true)
            .accessibilityIdentifier(A11yID.homeScreen)
            .navigationDestination(for: Route.self) { route in
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
        .tint(AtlasTheme.accent)
        .onAppear {
            nightly.registerOpenAutonomos {
                path = NavigationPath()
                path.append(Route.autonomos)
            }
            #if DEBUG
            nightly.installDemoIfRequested()
            #endif
        }
        .task { if session.phase == .idle { await session.loadThreads() } }
        .task {
            // A linha CÓDIGO só fala com dado real: sem resposta, ela cala.
            let hub = codeHub ?? AtlasCodeHubModel(client: session.client)
            codeHub = hub
            await hub.refresh()
        }
        .task {
            if case .idle = session.arena.phase {
                await session.arena.refreshSummaryKeepingSnapshot()
            }
        }
        .onOpenURL { handleDeepLink($0) }
    }
}
