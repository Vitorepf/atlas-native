import SwiftUI
import AtlasCore

// Rotas: um workspace (repo), uma thread existente, ou conversa nova.
enum Route: Hashable {
    case workspace(key: String?, title: String)
    /// M0 · o grafo de UM repositório, escolhido no radar (M3).
    case codeGraph(repo: String)
    case thread(id: ThreadID, title: String)
    case new
    case conversas
    case search
    case autonomos
    case arena
    case code
}

// Home Workspaces-primeiro (estilo Cursor, tema Atlas): masthead Fraunces, lista
// de repos reais (campo `workspace` das threads) + "Todas" + "Adicionar". Entrar
// num workspace abre suas conversas com filtro de área.
struct RootView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var path = NavigationPath()
    @State private var codeHub: AtlasCodeHubModel?
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
        .onOpenURL { url in
            guard let link = AtlasDeepLink.parse(url) else { return }
            switch link {
            case .autonomos:
                path = NavigationPath()
                path.append(Route.autonomos)
            case .arena:
                path = NavigationPath()
                path.append(Route.arena)
            case .codeHome:
                path = NavigationPath()
                path.append(Route.code)
            case .code(let repo):
                path.append(Route.codeGraph(repo: repo))
            case .executionHome:
                // Widget "Seguir" sem trace: home; se há sessão viva real com
                // thread, abre a mais recente — nunca inventa conversa.
                path = NavigationPath()
                let live = (TurnPresence.shared.liveSessions + session.remoteLiveSessions)
                    .sorted { $0.startedAt < $1.startedAt }
                if let snap = live.last(where: { $0.threadId != nil }),
                   let threadId = snap.threadId {
                    path.append(Route.thread(id: threadId, title: snap.title))
                }
            case .execution(let traceId):
                Task { @MainActor in
                    guard let trace = try? await session.client.getAiInteraction(TraceID(traceId)).trace,
                          let rawThread = trace.threadId else { return }
                    let threadId = ThreadID(rawThread)
                    let title = session.threads.first(where: { $0.id == rawThread })?.title ?? "Execução Atlas"
                    path = NavigationPath()
                    path.append(Route.thread(id: threadId, title: title))
                }
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AtlasTheme.surface)
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: "person.fill").font(.system(size: 18)).foregroundStyle(AtlasTheme.textSecondary))
                .overlay(Circle().stroke(AtlasTheme.separator, lineWidth: 1))
            // A ponte para o Atlas Código mora aqui: equilibra a barra (2 à
            // esquerda, 2 à direita) e é a única porta do domínio — o hub
            // não repete a área. Silêncio quando saudável: badge SÓ com
            // exceção real (nunca ponto verde/afirmação sem varredura).
            CircleButton(icon: "point.3.connected.trianglepath.dotted",
                         badge: codeHub?.exception != nil) { path.append(Route.code) }
                .accessibilityLabel(codeHub?.exception == nil
                                    ? "Atlas Código"
                                    : "Atlas Código, \(codeHub?.exception?.count ?? 0) exceções")
                .accessibilityIdentifier(A11yID.topbarCode)
            Spacer()
            CircleButton(icon: "magnifyingglass") { path.append(Route.search) }
                .keyboardShortcut("k", modifiers: .command)
            CircleButton(icon: "plus") { path.append(Route.new) }
                .keyboardShortcut("n", modifiers: .command)
        }
        // Nameplate "Atlas" centralizado + filete dourado — a assinatura
        // editorial do masthead (mesma do ícone).
        .overlay {
            VStack(spacing: 5) {
                HStack(spacing: 4) {
                    Text("Atlas")
                        .font(AtlasFont.serif(24, .semibold))
                    Text("✦")
                        .font(AtlasFont.serif(15, .semibold))
                        .foregroundStyle(session.auditModeEnabled ? AtlasTheme.domOperacional : AtlasTheme.accent)
                }
                .foregroundStyle(AtlasTheme.textPrimary)
                Rectangle()
                    .fill(AtlasTheme.accent.opacity(0.6))
                    .frame(width: 30, height: 1.5)
                if session.auditModeEnabled {
                    Text("AUDITORIA")
                        .font(AtlasFont.mono(8))
                        .tracking(1.0)
                        .foregroundStyle(AtlasTheme.domOperacional)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Atlas")
            .accessibilityIdentifier(A11yID.auditMasthead)
            .accessibilityAddTraits(.isHeader)
            .onLongPressGesture(minimumDuration: 0.55) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                session.auditModeEnabled.toggle()
            }
            // Cap deliberado: em AXXXL o nameplate colidia com busca/+ (evidência
            // 03). Marca limita a própria escala; o CONTEÚDO escala livre.
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        }
    }

    // MARK: - Input pill → conversa nova

    private var inputBar: some View {
        Button { path.append(Route.new) } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus").font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30).background(Circle().fill(AtlasTheme.surfaceHi))
                Text("Escreva ao Atlas").font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
                Spacer()
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Capsule().fill(AtlasTheme.surface).overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
        }
        .buttonStyle(.plain)
        .keyboardShortcut("n", modifiers: .command)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}
