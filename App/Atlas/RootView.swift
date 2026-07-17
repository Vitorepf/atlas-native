import SwiftUI
import AtlasCore

// Home Workspaces-primeiro (estilo Cursor, tema Atlas): masthead Fraunces, lista
// de repos reais (campo `workspace` das threads) + "Todas" + "Adicionar". Entrar
// num workspace abre suas conversas com filtro de área.
// Destinations → RootView+Destinations.swift · Nightly → RootView+Nightly.swift
struct RootView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var path = NavigationPath()
    @State var codeHub: AtlasCodeHubModel?
    @State var nightly = NightlyProposalController.shared
    @State var homeWorkspaceFilter: String?

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
            .accessibilityLabel(homeScreenSpokenLabel())
            .accessibilityHint(homeScreenSpokenHint())
            .navigationDestination(for: Route.self) { rootDestination(for: $0) }
        }
        .tint(AtlasTheme.accent)
        .onAppear { registerNightlyOpen() }
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
