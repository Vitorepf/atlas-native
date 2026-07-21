import AtlasCore
import SwiftUI

// Cycle 044 fuse → RootView.swift

// Home Workspaces-primeiro (estilo Cursor, tema Atlas): masthead Fraunces, lista
// de repos reais (campo `workspace` das threads) + "Todas" + "Adicionar". Entrar
// num workspace abre suas conversas com filtro de área.
struct RootView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var path = NavigationPath()
    @State var codeHub: AtlasCodeHubModel?
    @State var nightly = NightlyProposalController.shared
    @State var showingProfile = false
    @State var showingNewPicker = false

    var body: some View {
        rootLifecycleChrome(
            NavigationStack(path: $path) {
                rootHomeStack
            }
        )
        // Sheet no root (não no Button): apresentação estável no XCUITest/iOS 26.
        .sheet(isPresented: $showingNewPicker) {
            AtlasWorkspacePickerSheet(
                client: session.client,
                title: "Nova conversa",
                onNoRepo: {
                    showingNewPicker = false
                    path.append(Route.new(workspaceKey: nil))
                }
            ) { key, title in
                showingNewPicker = false
                path.append(Route.workspace(key: key, title: title))
            }
        }
    }
}

extension RootView {
    func mastheadSpokenLabel(auditModeEnabled: Bool) -> String {
        auditModeEnabled ? "Atlas, modo auditoria" : "Atlas"
    }

    func mastheadSpokenHint() -> String {
        "pressione e segure para alternar modo auditoria"
    }
}

extension RootView {
    func inputPillSpokenLabel() -> String {
        "Escreva ao Atlas, nova conversa"
    }

    func inputPillSpokenHint() -> String {
        "abre a escolha: sem repositório ou um repositório recente"
    }
}

extension RootView {
    func searchSpokenLabel() -> String {
        "buscar conversas"
    }
}

extension RootView {
  @ViewBuilder
  var mastheadOverlay: some View {
    mastheadTitleStack
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(mastheadSpokenLabel(auditModeEnabled: session.auditModeEnabled))
    .accessibilityHint(mastheadSpokenHint())
    .accessibilityIdentifier(A11yID.auditMasthead)
    .accessibilityAddTraits(.isHeader)
    .onLongPressGesture(minimumDuration: 0.55) {
      AtlasMotion.softImpact(reduceMotion: reduceMotion)
      session.auditModeEnabled.toggle()
    }
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
  }
}

extension RootView {
    @ViewBuilder
    var mastheadAuditBadge: some View {
        if session.auditModeEnabled {
            Text("AUDITORIA")
                .font(AtlasFont.mono(8))
                .tracking(1.0)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
        }
    }
}

extension RootView {
  // A linha premium do site no clímax dela: ouro em fade nas duas pontas.
  var mastheadAccentRule: some View {
    LinearGradient(
      colors: [AtlasTheme.accent.opacity(0), AtlasTheme.accent.opacity(0.7),
               AtlasTheme.accent.opacity(0)],
      startPoint: .leading, endPoint: .trailing
    )
    .frame(width: 44, height: 1.5)
    .accessibilityHidden(true)
  }
}

extension RootView {
  var mastheadBrandRow: some View {
    HStack(spacing: 7) {
      Text("Atlas")
        .font(AtlasFont.serif(23, .semibold))
        .accessibilityHidden(true)
      Text("✦")
        .font(AtlasFont.serif(12, .semibold))
        .foregroundStyle(session.auditModeEnabled ? AtlasTheme.domOperacional : AtlasTheme.accent)
        .shadow(
          color: (session.auditModeEnabled ? AtlasTheme.domOperacional : AtlasTheme.accent)
            .opacity(0.35),
          radius: 5,
          y: 0
        )
        .accessibilityHidden(true)
    }
    .foregroundStyle(AtlasTheme.textPrimary)
  }
}

extension RootView {
  var mastheadTitleStack: some View {
    VStack(spacing: 5) {
      mastheadBrandRow
      mastheadAccentRule
      mastheadAuditBadge
    }
  }
}

extension RootView {
    var topBarTrailing: some View {
        // Só busca: o "+" saiu — a pílula "Escreva ao Atlas" é o único ponto
        // de partida (abre o picker: sem repositório ou um repo por recência).
        CircleButton(icon: "magnifyingglass") { path.append(Route.search) }
            .keyboardShortcut("k", modifiers: .command)
            .accessibilityLabel(searchSpokenLabel())
            .accessibilityHint("abre busca nas conversas carregadas")
            .accessibilityIdentifier(A11yID.topbarSearch)
    }
}

extension RootView {
  @ViewBuilder
  var topBar: some View {
    HStack(spacing: 12) {
      topBarAvatar
      topBarCodeButton
      Spacer()
      topBarTrailing
    }
    .overlay { mastheadOverlay }
  }
}

// (era decorativo — affordance falsa; ordem do operador 2026-07-18).

extension RootView {
    var topBarAvatar: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: UIAccessibility.isReduceMotionEnabled)
            showingProfile = true
        } label: {
            Image(systemName: "person.fill")
                .atlasSans(18)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 44, height: 44)
                .atlasGlassCircle()
                .contentShape(Circle())
        }
        .accessibilityIdentifier(A11yID.topbarProfile)
        .accessibilityLabel("perfil do operador")
        .accessibilityHint("abre seu perfil e o estado da sessão")
        .sheet(isPresented: $showingProfile) { AtlasProfileSheet() }
    }
}

extension RootView {
    var topBarCodeButton: some View {
        // Sem ponto vermelho (ordem 2026-07-18): a exceção fala DENTRO do
        // Código, com palavra — não com pingo no chrome.
        CircleButton(icon: "point.3.connected.trianglepath.dotted") { path.append(Route.code) }
            .accessibilityLabel(RootHomeSections.codeTopBarLabel(hub: codeHub))
            .accessibilityHint("abre radar de repositórios")
            .accessibilityIdentifier(A11yID.topbarCode)
    }
}

extension RootView {
    func handleExecutionFamilyDeepLink(_ link: AtlasDeepLink) {
        switch link {
        case .executionHome:
            handleExecutionHomeDeepLink()
        case .execution(let traceId):
            handleExecutionDeepLink(traceId: traceId)
        default:
            break
        }
    }
}

extension RootView {
    func handleSurfaceOrCodeDeepLink(_ link: AtlasDeepLink) {
        switch link {
        case .autonomos, .arena, .codeHome, .code(_):
            handleSurfaceDeepLink(link)
        default:
            break
        }
    }
}

extension RootView {
    func handleDeepLink(_ url: URL) {
        guard let link = AtlasDeepLink.parse(url) else { return }
        switch link {
        case .autonomos, .arena, .codeHome, .code(_):
            handleSurfaceOrCodeDeepLink(link)
        case .executionHome, .execution(_):
            handleExecutionFamilyDeepLink(link)
        }
    }
}

extension RootView {
    func handleExecutionDeepLink(traceId: String) {
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

extension RootView {
    func handleExecutionHomeDeepLink() {
        // Widget "Seguir" sem trace: home; se há sessão viva real com
        // thread, abre a mais recente — nunca inventa conversa.
        path = NavigationPath()
        let live = (TurnPresence.shared.liveSessions + session.remoteLiveSessions)
            .sorted { $0.startedAt < $1.startedAt }
        if let snap = live.last(where: { $0.threadId != nil }),
           let threadId = snap.threadId {
            path.append(Route.thread(id: threadId, title: snap.title))
        }
    }
}

extension RootView {
    func handleCodeGraphDeepLink(_ link: AtlasDeepLink) {
        if case .code(let repo) = link {
            path.append(Route.codeGraph(repo: repo))
        }
    }
}

extension RootView {
    func handleArenaOrCodeDeepLink(_ link: AtlasDeepLink) {
        switch link {
        case .arena:
            path = NavigationPath()
            path.append(Route.arena)
        case .codeHome:
            path = NavigationPath()
            path.append(Route.code)
        default:
            break
        }
    }
}

extension RootView {
    func handleAutonomosDeepLink() {
        path = NavigationPath()
        path.append(Route.autonomos)
    }
}

extension RootView {
    func handleHubDeepLink(_ link: AtlasDeepLink) {
        switch link {
        case .autonomos:
            handleAutonomosDeepLink()
        case .arena, .codeHome:
            handleArenaOrCodeDeepLink(link)
        default:
            break
        }
    }
}

extension RootView {
    func handleSurfaceDeepLink(_ link: AtlasDeepLink) {
        handleHubDeepLink(link)
        handleCodeGraphDeepLink(link)
    }
}

// Véu editorial (teal + gold) sob a lista; silêncio, não dashboard.

extension RootView {
    var homeAtmosphere: some View {
        ZStack {
            AtlasTheme.bg
            RadialGradient(
                colors: [AtlasTheme.accent.opacity(0.045), .clear],
                center: .top,
                startRadius: 20,
                endRadius: 320
            )
            RadialGradient(
                colors: [AtlasTheme.prussian.opacity(0.055), .clear],
                center: UnitPoint(x: 1.05, y: 0.82),
                startRadius: 10,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

extension RootView {
    // A11y no CONTAINER carimbava identifier/label em todos os filhos (composer
    // virava "Atlas, início"; linhas de OPERAÇÃO ficavam mudas no VoiceOver).
    // Tela não fala por cima dos elementos: cada um carrega a própria voz.
    func rootHomeNavChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { rootDestination(for: $0) }
    }
}

extension RootView {
    var rootHomeStack: some View {
        rootHomeNavChrome(
            ZStack(alignment: .bottom) {
                homeAtmosphere
                rootHomeSectionsStack
                inputBar
            }
        )
    }
}

extension RootView {
    @ViewBuilder
    var rootHomeSectionsStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 4)
                .padding(.bottom, 14)

            RootHomeSections(
                reduceMotion: reduceMotion,
                onNavigate: { path.append($0) },
                onOpenThread: { id, title in path.append(Route.thread(id: id, title: title)) }
            )
        }
    }
}

extension RootView {
    @ViewBuilder
    var inputBar: some View {
        // A pílula é o ÚNICO ponto de partida (o "+" saiu): abre o picker do
        // Cursor — "Sem repositório" (conversa geral) ou um repo por recência.
        Button {
            AtlasMotion.softImpact(reduceMotion: UIAccessibility.isReduceMotionEnabled)
            showingNewPicker = true
        } label: {
            inputBarContent
        }
        .buttonStyle(.plain)
        .keyboardShortcut("n", modifiers: .command)
        .accessibilityLabel(inputPillSpokenLabel())
        .accessibilityHint(inputPillSpokenHint())
        .accessibilityIdentifier(A11yID.homeInputPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(inputBarBackground)
    }
}

extension RootView {
    var inputBarBackground: some View {
        LinearGradient(
            colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// Mesma gramática de BreathingGlyph, escala de composer.

extension RootView {
    struct HomeComposerStar: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var on = false

        var body: some View {
            ZStack {
                Circle()
                    .fill(AtlasTheme.goldVeil)
                    .blur(radius: 6)
                    .scaleEffect(on ? 1.18 : 0.92)
                    .opacity(on ? 0.95 : 0.4)
                Text("✦")
                    .font(AtlasFont.serif(16))
                    .foregroundStyle(AtlasTheme.accent)
                    .shadow(color: AtlasTheme.accent.opacity(0.35), radius: 5, y: 0)
            }
            .frame(width: 30, height: 30)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(AtlasMotion.breath(2.8)) { on = true }
            }
            .accessibilityHidden(true)
        }
    }
}

extension RootView {
    // A pílula agêntica: ✦ vivo + Liquid Glass + fio de ouro artesanal.
    var inputBarContent: some View {
        HStack(spacing: 12) {
            HomeComposerStar()
            Text("Escreva ao Atlas")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
        .frame(minHeight: 48) // HIG 44pt; same breath as AgenticPill / workspace pill
        .contentShape(Capsule())
        .atlasGlassCapsule()
        .overlay(
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            AtlasTheme.accent.opacity(0.22),
                            AtlasTheme.accent.opacity(0.04),
                            AtlasTheme.accent.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        )
    }
}

extension RootView {
    func rootLifecycleArena<Content: View>(_ content: Content) -> some View {
        content.task {
#if DEBUG
            // Harness ANTES de qualquer rede — UITest não espera Mac/servidor.
            if ProcessInfo.processInfo.arguments.contains("-atlas.uitest.newConversation") {
                if path.isEmpty { path.append(Route.new(workspaceKey: nil)) }
                return
            }
            if session.arena.installVisualScenarioIfRequested() {
                if path.isEmpty { path.append(Route.arena) }
                return
            }
#endif
            if case .idle = session.arena.phase {
                await session.arena.refreshSummaryKeepingSnapshot()
            }
        }
    }
}

extension RootView {
    func rootLifecycleCodeHub<Content: View>(_ content: Content) -> some View {
        content.task {
            // A linha CÓDIGO só fala com dado real: sem resposta, ela cala.
            let hub = codeHub ?? AtlasCodeHubModel(client: session.client)
            codeHub = hub
            await hub.refresh()
        }
    }
}

extension RootView {
    func rootLifecycleDeepLink<Content: View>(_ content: Content) -> some View {
        content.onOpenURL { handleDeepLink($0) }
    }
}

extension RootView {
    func rootLifecycleThreads<Content: View>(_ content: Content) -> some View {
        content.task { if session.phase == .idle { await session.loadThreads() } }
    }
}

extension RootView {
    func rootLifecycleTintAppear<Content: View>(_ content: Content) -> some View {
        content
            .tint(AtlasTheme.accent)
            .onAppear { registerNightlyOpen() }
    }
}

extension RootView {
    func rootLifecycleChrome<Content: View>(_ content: Content) -> some View {
        rootLifecycleDeepLink(
            rootLifecycleArena(
                rootLifecycleCodeHub(
                    rootLifecycleThreads(
                        rootLifecycleTintAppear(content)
                    )
                )
            )
        )
    }
}

extension RootView {
    func registerNightlyOpen() {
        nightly.registerOpenAutonomos {
            path = NavigationPath()
            path.append(Route.autonomos)
        }
        #if DEBUG
        nightly.installDemoIfRequested()
        #endif
    }
}

extension RootView {
    @ViewBuilder
    func rootConversationRoutes(for route: Route) -> some View {
        switch route {
        case .workspace(_, _), .thread(_, _), .new, .conversas, .search:
            rootConversationDestination(for: route)
        default:
            EmptyView()
        }
    }
}

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
        ConversationView(
            client: session.client,
            threadId: nil,
            title: workspaceKey.map { key in
                session.workspaces.first(where: { $0.id == key })?.name ?? key
            } ?? "Nova conversa",
            workspace: workspaceKey
        )
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
        ConversationView(client: session.client, threadId: id, title: title)
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
