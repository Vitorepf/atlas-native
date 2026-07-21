import AtlasCore
import SwiftUI
import UIKit
import Foundation

// Cycle 044 fuse → RootView.swift

// Rotas: um workspace (repo), uma thread existente, ou conversa nova.
enum Route: Hashable {
    case workspace(key: String?, title: String)
    /// M0 · o grafo de UM repositório, escolhido no radar (M3).
    case codeGraph(repo: String)
    case thread(id: ThreadID, title: String)
    /// Conversa nova; com workspaceKey ela já nasce NO workspace (Cursor-parity).
    case new(workspaceKey: String?)
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
    .accessibilityAction(named: session.auditModeEnabled ? "Desligar auditoria" : "Ligar auditoria") {
      AtlasMotion.softImpact(reduceMotion: reduceMotion)
      session.auditModeEnabled.toggle()
    }
    .onLongPressGesture(minimumDuration: 0.55) {
      // Soft: audit chrome is presentation preference (matches profile toggle).
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
            Text("Auditoria")
                .font(AtlasFont.mono(8))
                .tracking(0.4)
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
    HStack(spacing: 8) {
      Text("Atlas")
        .font(AtlasFont.serif(24, .semibold))
        .accessibilityHidden(true)
      Text("✦")
        .font(AtlasFont.serif(13, .semibold))
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
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            showingProfile = true
        } label: {
            Image(systemName: "person.fill")
                .atlasSans(18)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 48, height: 48)
                .atlasGlassCircle()
                .contentShape(Circle())
        }
        .accessibilityIdentifier(A11yID.topbarProfile)
        .accessibilityLabel("perfil do operador")
        .accessibilityHint("abre seu perfil e o estado da sessão")
        .accessibilityAddTraits(.isButton)
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
            // Soft: home write pill is invitation (AgenticPill class).
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            showingNewPicker = true
        } label: {
            inputBarContent
        }
        .buttonStyle(.plain)
        .keyboardShortcut("n", modifiers: .command)
        .accessibilityLabel(inputPillSpokenLabel())
        .accessibilityHint(inputPillSpokenHint())
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(10) // primary home write surfaces first in VO
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
        .padding(.vertical, 14)
        .frame(minHeight: 52) // match AgenticPill / workspace invite breath
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



// Gesto de voltar pela borda — devolvido às telas de chrome próprio.
//
// UIKit desliga o interactivePopGestureRecognizer quando a barra nativa está
// oculta. O delegate vive no PRÓPRIO UINavigationController (viewDidLoad é
// @objc — override em extension é legal): é o único anexo que o NavigationStack
// do iOS 18+ não re-seta. O shim embutido por tela (SwipeBackEnabler) nunca
// segurava o delegate e foi removido — provado por AtlasSwipeBackTests.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    /// Só permite o pop quando há para onde voltar — a raiz nunca trava.
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}


// Com back visual oculto, o UIKit desliga o pop da borda. O delegate global
// (SwipeBackEnabler) já existe; este shim só religa `isEnabled` na tela.

struct NavigationInteractivePopEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Controller()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        (uiViewController as? Controller)?.enablePopIfNeeded()
    }

    private final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            enablePopIfNeeded()
        }

        func enablePopIfNeeded() {
            guard let nav = navigationController else { return }
            nav.interactivePopGestureRecognizer?.isEnabled = nav.viewControllers.count > 1
        }
    }
}


/// Conteúdo da home (estados + CONVERSAS / OPERAÇÃO / WORKSPACES / VIVO AGORA).
/// Route e NavigationStack ficam no shell RootView.
struct RootHomeSections: View {
    @Environment(AtlasSession.self) var session
    var reduceMotion: Bool
    var onNavigate: (Route) -> Void
    @State private var showingWorkspacePicker = false
    var onOpenThread: (ThreadID, String) -> Void

    /// WORKSPACES some quando não há pastas reais.
    private var showsWorkspacesSection: Bool { !session.workspaces.isEmpty }

    private var freeThreadCount: Int {
        session.threads.filter { $0.workspace == nil }.count
    }

    private var homeConversationThreadCount: Int { freeThreadCount }

    private var homeConversationCount: Int? {
        let n = homeConversationThreadCount
        return n > 0 ? n : nil
    }

    private var auditDetail: String {
        let n = homeConversationCount ?? 0
        return "auditoria · livres · \(n) threads"
    }

    private var showsLiveNowSection: Bool {
        !TurnPresence.shared.liveSessions.isEmpty || !session.remoteLiveSessions.isEmpty
    }

    var body: some View {
        switch session.phase {
        case .idle where session.threads.isEmpty, .loading where session.threads.isEmpty:
            loadingHome
        case .failed where session.threads.isEmpty:
            failureSection
        default:
            loadedHome
        }
    }

    // MARK: - Loading / failure

    private var loadingHome: some View {
        centered {
            WorkspaceLoadingEmpty(
                reduceMotion: reduceMotion,
                text: "abrindo o Atlas…",
                spoken: "abrindo o Atlas",
                topPadding: 0
            )
            .accessibilityIdentifier(A11yID.homeLoading)
        }
    }

    private var failureSection: some View {
        centered {
            AtlasNetworkFailureEmpty(
                kind: session.failureKind,
                hasToken: session.hasToken,
                host: session.host,
                topPadding: 0,
                retryHint: "reconecta ao servidor Atlas",
                retryAccessibilityIdentifier: A11yID.homeRetry,
                accessibilityIdentifier: A11yID.homeOffline,
                onRetry: { Task { await session.loadThreads() } }
            )
        }
    }

    // MARK: - Loaded

    private var loadedHome: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if showsLiveNowSection {
                    LiveNowSection(
                        localSessions: TurnPresence.shared.liveSessions,
                        remoteSessions: session.remoteLiveSessions,
                        onOpen: onOpenThread
                    )
                }
                conversasSection
                rowDivider
                operacaoSection
                if showsWorkspacesSection {
                    rowDivider
                    workspacesSection
                }
            }
            .padding(.bottom, 96)
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }

    // MARK: - CONVERSAS

    @ViewBuilder
    private var conversasSection: some View {
        sectionLabel("Conversas", accessibilityID: A11yID.homeConversasSection)
        WorkspaceRow(
            icon: "bubble.left.and.bubble.right",
            name: "Conversas livres",
            count: homeConversationCount,
            detail: session.auditModeEnabled ? auditDetail : nil,
            a11yID: A11yID.homeConversasEntry,
            spokenOverride: conversasEntrySpokenLabel(),
            spokenHint: "abre as conversas sem workspace"
        ) {
            onNavigate(.conversas)
        }
    }

    private func conversasEntrySpokenLabel() -> String {
        var parts = ["Conversas livres"]
        let n = homeConversationThreadCount
        if n == 0 {
            parts.append("nenhuma conversa")
        } else {
            parts.append("\(n) conversa\(n == 1 ? "" : "s")")
        }
        if session.auditModeEnabled {
            parts.append(auditDetail)
        }
        return parts.joined(separator: ", ")
    }

    // MARK: - OPERAÇÃO

    @ViewBuilder
    private var operacaoSection: some View {
        sectionLabel("Operação", accessibilityID: A11yID.homeOperacaoSection)
        WorkspaceRow(
            icon: "bolt.horizontal.circle",
            name: "Autônomos",
            count: nil,
            a11yID: A11yID.homeAutonomosEntry,
            spokenOverride: "Autônomos, abre catálogo de escopos soberanos"
        ) {
            onNavigate(.autonomos)
        }
        rowDivider
        WorkspaceRow(
            icon: "chart.line.uptrend.xyaxis",
            name: "Arena",
            count: nil,
            a11yID: A11yID.arenaHomeEntry,
            spokenOverride: arenaSpokenLabel(
                domainUnavailable: session.arena.isDomainUnavailable
            ),
            spokenHint: "abre medição de regressão"
        ) {
            onNavigate(.arena)
        }
    }

    private func arenaSpokenLabel(domainUnavailable: Bool) -> String {
        if domainUnavailable { return "Arena, \(ArenaModel.domainUnavailableCopy)" }
        return "Arena, abre medição de regressão"
    }

    // MARK: - WORKSPACES

    @ViewBuilder
    private var workspacesSection: some View {
        sectionLabel("Workspaces", accessibilityID: A11yID.homeWorkspacesSection)
        ForEach(session.recentWorkspaces(3)) { ws in
            rowDivider
            WorkspaceRow(
                icon: "folder",
                name: ws.name,
                count: ws.count > 0 ? ws.count : nil,
                a11yID: A11yID.homeWorkspace(ws.id),
                spokenOverride: workspaceSpokenLabel(
                    name: ws.name,
                    count: ws.count > 0 ? ws.count : nil
                ),
                spokenHint: "abre conversas deste workspace"
            ) {
                onNavigate(.workspace(key: ws.id, title: ws.name))
            }
        }
        rowDivider
        WorkspaceRow(
            icon: "folder.badge.plus",
            name: "Adicionar workspace",
            count: nil,
            a11yID: A11yID.homeAddWorkspace,
            spokenOverride: "adicionar workspace",
            spokenHint: "escolhe um repositório do Mac"
        ) {
            showingWorkspacePicker = true
        }
        .sheet(isPresented: $showingWorkspacePicker) {
            AtlasWorkspacePickerSheet(client: session.client) { key, title in
                showingWorkspacePicker = false
                onNavigate(.workspace(key: key, title: title))
            }
        }
    }

    private func workspaceSpokenLabel(name: String, count: Int?) -> String {
        guard let count else { return name }
        return "\(name), \(count) conversa\(count == 1 ? "" : "s")"
    }

    /// Spoken da top bar Código (RootView chrome).
    static func codeTopBarLabel(hub: AtlasCodeHubModel?) -> String {
        guard let hub else { return "Atlas Código" }
        if let exception = hub.exception {
            return "Atlas Código, \(exception.count) exceções em \(exception.repo)"
        }
        return "Atlas Código, código quieto"
    }

    // MARK: - Layout

    private var rowDivider: some View {
        LinearGradient(
            colors: [AtlasTheme.separator, AtlasTheme.separator, AtlasTheme.separator.opacity(0)],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(height: 1)
        .padding(.leading, AtlasTheme.Space.screen + 42)
    }

    private func centered<V: View>(@ViewBuilder _ v: () -> V) -> some View {
        VStack { Spacer(); v(); Spacer() }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


/// "VIVO AGORA" — home vira cockpit quando há sessão neste processo.
/// Sem sessões a seção não existe. Com 2+ = Session Hub (zero Route nova).
struct LiveNowSection: View {
    let localSessions: [LiveSessionSnapshot]
    let remoteSessions: [LiveSessionSnapshot]
    let onOpen: (ThreadID, String) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var sessions: [LiveSessionSnapshot] {
        Self.merged(local: localSessions, remote: remoteSessions)
    }

    var isHub: Bool { sessions.count >= 2 }
    var remoteCount: Int { sessions.filter(\.isRemote).count }

    var body: some View {
        VStack(alignment: .leading, spacing: isHub ? 0 : 12) {
            header
            ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                if isHub, index > 0 {
                    Rectangle()
                        .fill(AtlasTheme.separator.opacity(0.55))
                        .frame(height: 1)
                        .padding(.vertical, 10)
                        .accessibilityHidden(true)
                }
                rowCell(index: index, session: session)
            }
        }
        .padding(14)
        .atlasCard()
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 18)
        .accessibilityIdentifier(A11yID.liveNowSection)
        // Contain without fused section label so each LiveNowRow stays focusable.
        .accessibilityElement(children: .contain)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: sessions.map(\.id))
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("Vivo agora")
                .font(AtlasFont.serif(13, .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(Self.spokenSectionLabel(
                    isHub: isHub, count: sessions.count, remoteCount: remoteCount
                ))
            if isHub {
                Text("× \(sessions.count)")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
                if remoteCount > 0 {
                    Text("· \(remoteCount) remota\(remoteCount == 1 ? "" : "s")")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, isHub ? 12 : 0)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Self.spokenSectionLabel(
            isHub: isHub, count: sessions.count, remoteCount: remoteCount
        ))
    }

    private func rowCell(index: Int, session: LiveSessionSnapshot) -> some View {
        LiveNowRow(
            session: session,
            hubMode: isHub,
            hubIndex: isHub ? index : nil,
            hubCount: isHub ? sessions.count : nil,
            reduceMotion: reduceMotion,
            remoteBadgeID: session.isRemote ? A11yID.liveNowRemoteBadge(index) : nil
        ) {
            // Soft haptic already fires in LiveNowRow — avoid double impact.
            guard let threadId = session.threadId else { return }
            onOpen(threadId, session.title)
        }
        .accessibilityIdentifier(A11yID.liveNowRow(index))
        .transition(reduceMotion ? .opacity : .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 8)),
            removal: .opacity
        ))
    }

    static func spokenSectionLabel(isHub: Bool, count: Int, remoteCount: Int) -> String {
        guard isHub else { return "vivo agora" }
        var label = "vivo agora, \(count) sessões vivas"
        if remoteCount > 0 {
            label += ", \(remoteCount) remota\(remoteCount == 1 ? "" : "s") em outra superfície"
        }
        return label
    }

    static func merged(local: [LiveSessionSnapshot], remote: [LiveSessionSnapshot]) -> [LiveSessionSnapshot] {
        local + filteredRemote(local: local, remote: remote)
    }

    static func filteredRemote(
        local: [LiveSessionSnapshot],
        remote: [LiveSessionSnapshot]
    ) -> [LiveSessionSnapshot] {
        var seenThreads = Set(local.compactMap { $0.threadId?.rawValue })
        var seenRemoteIDs: Set<String> = []
        return remote.filter { session in
            if let thread = session.threadId?.rawValue {
                guard !seenThreads.contains(thread) else { return false }
                seenThreads.insert(thread)
                return true
            }
            return seenRemoteIDs.insert(session.id).inserted
        }
    }
}


/// Uma linha do Session Hub / VIVO AGORA — title, phase, timing, elapsed.
struct LiveNowRow: View {
    let session: LiveSessionSnapshot
    let hubMode: Bool
    let hubIndex: Int?
    let hubCount: Int?
    let reduceMotion: Bool
    let remoteBadgeID: String?
    let onTap: () -> Void

    var navigable: Bool { session.threadId != nil }

    var body: some View {
        Group {
            if navigable {
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onTap()
                } label: {
                    rowContent
                }
                .buttonStyle(PressableScale())
            } else {
                rowContent
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenLabel(hubIndex: hubIndex, hubCount: hubCount))
        .atlasAccessibilityHint(navigable ? "abre conversa desta sessão" : nil)
        .accessibilityAddTraits(liveNowTraits)
    }

    /// Running sessions update elapsed copy; respect Reduce Motion.
    private var liveNowTraits: AccessibilityTraits {
        let live = session.timing == .running && !reduceMotion
        if navigable {
            return live ? [.isButton, .updatesFrequently] : .isButton
        }
        return live ? .updatesFrequently : []
    }

    private var rowContent: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    BreathingDiamond(
                        size: 8,
                        reduceMotion: reduceMotion || session.timing != .running
                    )
                    titleStack(now: context.date)
                }
                Spacer(minLength: 0)
                if navigable {
                    Image(systemName: "chevron.right")
                        .atlasSans(12, .semibold)
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 6)
            .frame(minHeight: 52, alignment: .center)
            .opacity(isLongPaused(now: context.date) ? 0.58 : 1)
        }
    }

    private func titleStack(now: Date) -> some View {
        VStack(alignment: .leading, spacing: hubMode ? 4 : 3) {
            Text(session.title)
                .font(AtlasFont.serif(17, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .layoutPriority(1)
            HStack(spacing: 6) {
                Text(session.phaseTitle)
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                if session.isRemote { remoteBadge }
            }
            timingLine(now: now)
        }
    }

    private var remoteBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.triangle.branch")
                .atlasSans(8, .semibold)
                .accessibilityHidden(true)
            Text("Remota")
                .font(AtlasFont.mono(9))
                .tracking(0.4)
                .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.accent)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Capsule().fill(AtlasTheme.goldVeil))
        .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("sessão remota em outra superfície")
        .atlasAccessibilityIdentifier(remoteBadgeID)
    }

    private func timingLine(now: Date) -> some View {
        HStack(spacing: 6) {
            Text(timingWord)
                .font(AtlasFont.mono(10))
                .tracking(0.3)
                .foregroundStyle(timingColor)
            if session.timing != .finished {
                Text("·")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                clockView(now: now)
                    .accessibilityLabel(clockAccessibilityLabel(now: now))
            }
            if session.timing == .paused, let age = pauseAgeHours(now: now) {
                Text("· há \(age)h")
                    .font(AtlasFont.serifItalic(12))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
    }

    private var timingWord: String {
        switch session.timing {
        case .running: "em execução"
        case .paused: "pausado"
        case .finished: "concluído"
        }
    }

    private var timingColor: Color {
        switch session.timing {
        case .running: AtlasTheme.accent
        case .paused: AtlasTheme.textTertiary
        case .finished: AtlasTheme.textSecondary
        }
    }

    @ViewBuilder
    private func clockView(now: Date) -> some View {
        switch session.timing {
        case .running:
            TimelineView(.periodic(from: .now, by: reduceMotion ? 60 : 1)) { context in
                clockText(Self.formatClock(
                    elapsedMs: session.elapsedActiveMs,
                    runningSince: session.runningSince,
                    now: context.date,
                    paused: false
                ))
            }
        case .paused:
            clockText(Self.formatClock(
                elapsedMs: session.elapsedActiveMs,
                runningSince: nil,
                now: now,
                paused: true
            ))
        case .finished:
            EmptyView()
        }
    }

    private func clockText(_ value: String) -> some View {
        Text(value)
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textSecondary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
    }

    private func clockAccessibilityLabel(now: Date) -> String {
        guard let clock = spokenClock(now: now) else {
            return "Tempo ativo indisponível"
        }
        return session.timing == .paused
            ? "tempo ativo congelado em \(clock)"
            : "tempo ativo \(clock)"
    }

    // MARK: - Spoken

    private func spokenLabel(hubIndex: Int?, hubCount: Int?, now: Date = .now) -> String {
        let prefix = hubPositionPrefix(index: hubIndex, count: hubCount)
        switch session.timing {
        case .running:
            if let clock = spokenClock(now: now) {
                return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução há \(clock)"
            }
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução, tempo ativo indisponível"
        case .paused:
            let age = pauseAgeHours(now: now).map { ", há \($0) horas" } ?? ""
            if let clock = spokenClock(now: now) {
                return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado em \(clock)\(age)"
            }
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado, tempo ativo indisponível\(age)"
        case .finished:
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), concluído"
        }
    }

    private var remoteSuffix: String {
        session.isRemote ? ", sessão remota em outra superfície" : ""
    }

    private func hubPositionPrefix(index: Int?, count: Int?) -> String {
        guard let index, let count, count >= 2 else { return "" }
        return "sessão \(index + 1) de \(count), "
    }

    private func spokenClock(now: Date) -> String? {
        guard session.elapsedActiveMs != nil else { return nil }
        return Self.formatClock(
            elapsedMs: session.elapsedActiveMs,
            runningSince: session.runningSince,
            now: now,
            paused: session.timing == .paused
        )
    }

    // MARK: - Pause / clock math

    func pauseAgeHours(now: Date) -> Int? {
        guard session.timing == .paused, let pauseTimestamp = session.pauseTimestamp else { return nil }
        let seconds = max(0, now.timeIntervalSince(pauseTimestamp))
        guard seconds >= 30 * 60 else { return nil }
        return max(1, Int(seconds / 3600))
    }

    func isLongPaused(now: Date) -> Bool {
        pauseAgeHours(now: now) != nil
    }

    /// Relógio canônico: `elapsedActiveMs` + (now − runningSince) quando running.
    static func formatClock(
        elapsedMs: Int?,
        runningSince: Date?,
        now: Date,
        paused: Bool
    ) -> String {
        guard let base = elapsedMs else { return "—" }
        var ms = base
        if !paused, let since = runningSince {
            ms += max(0, Int(now.timeIntervalSince(since) * 1000))
        }
        let s = ms / 1000
        return s >= 3600
            ? String(format: "%d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
            : String(format: "%d:%02d", s / 60, s % 60)
    }
}


// Cycle 044 fuse → SearchView.swift

// Busca REAL sobre as conversas (o dado já vive na sessão — filtro local,
// zero rede na casca). Sem query: recentes reais ou silêncio. Com query:
// título folded (caso+acento insensível). Offline ≠ vazio editorial.
struct SearchView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var query = ""
    @FocusState var focused: Bool

    var body: some View {
        searchA11yChrome(searchBackgroundShell)
    }
}

extension SearchView {
    var searchBackgroundShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            searchLayout
        }
    }
}

extension SearchView {
    var searchLayout: some View {
        VStack(spacing: 0) {
            SearchViewHeader(query: $query, focused: $focused)
            list
        }
    }
}

struct SearchViewHeader: View {
    @Binding var query: String
    @FocusState.Binding var focused: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            searchBackButton
            searchFieldCapsule
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 10)
    }
}

extension SearchViewHeader {
    var searchBackButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 48, height: 48).atlasGlassCircle()
                .contentShape(Circle())
        }
        .accessibilityLabel("voltar")
        .accessibilityHint("fecha a busca")
        .accessibilityAddTraits(.isButton)
    }
}

extension SearchViewHeader {
    func clearSearchQuery() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        query = ""
    }
}

extension SearchViewHeader {
    @ViewBuilder
    var searchClearButton: some View {
        if !query.isEmpty {
            searchClearA11y(
                Button(action: clearSearchQuery) {
                    searchClearIcon
                }
            )
        }
    }
}

extension SearchViewHeader {
    func searchClearA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .accessibilityLabel("limpar busca")
            .accessibilityHint("remove o texto e volta aos recentes")
            .accessibilityIdentifier(A11yID.searchClear)
            .accessibilityAddTraits(.isButton)
    }
}

extension SearchViewHeader {
    var searchClearIcon: some View {
        Image(systemName: "xmark.circle.fill")
            .atlasSans(16).foregroundStyle(AtlasTheme.textTertiary)
            .frame(width: 48, height: 48)
            .contentShape(Circle())
    }
}

extension SearchViewHeader {
    var searchFieldCapsule: some View {
        searchFieldLeading
            .padding(.horizontal, 14).padding(.vertical, 10)
            .frame(minHeight: 48) // HIG 44+; match primary chrome breath
            .background(Capsule().fill(AtlasTheme.surface)
                .overlay(Capsule().stroke(focused ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: focused)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: query.isEmpty)
    }
}

extension SearchViewHeader {
    var searchFieldInput: some View {
        ZStack(alignment: .leading) {
            searchFieldPlaceholder
            TextField("", text: $query)
                .font(AtlasFont.serif(15)).foregroundStyle(AtlasTheme.textPrimary)
                .tint(AtlasTheme.accent).focused($focused)
                .submitLabel(.search)
                .accessibilityLabel(spokenFieldLabel)
                .accessibilityHint("filtra só conversas já carregadas na sessão")
                .accessibilityIdentifier(A11yID.searchField)
        }
    }
}

extension SearchViewHeader {
    var searchFieldLeading: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            searchFieldInput
            searchClearButton
        }
    }
}

extension SearchViewHeader {
    var searchFieldPlaceholder: some View {
        Text("Buscar conversas")
            .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
            .opacity(query.isEmpty ? 1 : 0).allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

extension SearchViewHeader {
    var spokenFieldLabel: String {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "buscar conversas" }
        return "buscar conversas, \(trimmed)"
    }
}

extension SearchView {
    func searchA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(A11yID.searchScreen)
            // Contain without fused screen label so field/results stay focusable.
            .accessibilityElement(children: .contain)
            .onAppear { focused = true }
    }
}

extension SearchResultsSection {
    /// Mesma régua da lista de Conversas: "novo" na maioria de 6+ linhas
    /// não discrimina — silencia em bloco.
    var newBadgeSaturated: Bool {
        results.count >= 6
            && results.lazy.filter(ConversationModel.hasNewerContent).count * 2 > results.count
    }

    @ViewBuilder
    var resultsThreadLoop: some View {
        let saturated = newBadgeSaturated
        ForEach(results) { t in
            SearchThreadLink(thread: t, reduceMotion: reduceMotion, newBadgeSuppressed: saturated)
            if t.id != results.last?.id {
                Divider().overlay(AtlasTheme.separator)
                    .padding(.leading, AtlasTheme.Space.screen + 36)
            }
        }
    }
}

struct SearchResultsSection: View {
    let results: [AtlasAiThread]
    let query: String
    let reduceMotion: Bool

    var body: some View {
        Group {
            resultsCaption
            resultsThreadLoop
        }
    }
}

extension SearchResultsSection {
    var resultsCaption: some View {
        Text("\(results.count) resultado\(results.count == 1 ? "" : "s")")
            .font(AtlasFont.mono(10, .semibold)).tracking(0.6)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("\(results.count) conversa\(results.count == 1 ? "" : "s") com ‘\(query)’")
            .accessibilityIdentifier(A11yID.searchResultsCaption)
    }
}

extension SearchView {
    /// Só threads já carregadas na sessão — zero placeholder ou sugestão inventada.
    var recentThreads: [AtlasAiThread] {
        Array(session.threads.prefix(12))
    }
}

extension SearchView {
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    var isBrowsingRecent: Bool { trimmedQuery.isEmpty }
}

extension SearchView {
    var showsLoadingShell: Bool {
        guard session.threads.isEmpty else { return false }
        switch session.phase {
        case .idle, .loading: return true
        default: return false
        }
    }
}

extension SearchView {
    var showsNetworkFailure: Bool {
        guard session.threads.isEmpty else { return false }
        if case .failed = session.phase { return true }
        return false
    }
}

extension SearchView {
    var searchResults: [AtlasAiThread] {
        let q = trimmedQuery.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        guard !q.isEmpty else { return [] }
        return session.threads.filter {
            $0.title.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .contains(q)
        }
    }
}

struct SearchMissEmpty: View {
    let query: String
    let loadedThreadCount: Int

    private var headline: String {
        loadedThreadCount >= 100
            ? "“Nada com ‘\(query)’ nas 100 conversas mais recentes.”"
            : "“Nada com ‘\(query)’.”"
    }

    var body: some View {
        AtlasEditorialGlyphEmpty(
            headline: headline,
            footnote: "Tente outra frase · a busca olha títulos e trechos recentes",
            accessibilityIdentifier: A11yID.searchEmpty,
            spokenLabel: "\(headline) Tente outra frase"
        )
    }
}

extension SearchThreadLink {
    var threadNavigationLink: some View {
        NavigationLink(value: Route.thread(id: ThreadID(thread.id), title: thread.title)) {
            ThreadRow(thread: thread, newBadgeSuppressed: newBadgeSuppressed, ownsAccessibility: false)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
        })
    }
}

extension SearchThreadLink {
    func threadLinkTransition<Content: View>(_ content: Content) -> some View {
        let running = TurnPresence.shared.runningTitles.contains(thread.title)
        return content
            .accessibilityLabel(SearchThreadLink.spokenLabel(thread))
            .accessibilityHint(running ? "Atlas executando nesta conversa" : "abre a conversa")
            .accessibilityAddTraits(
                running && !reduceMotion
                    ? [.isButton, .updatesFrequently]
                    : .isButton
            )
            .accessibilityIdentifier(A11yID.searchResult(thread.id))
            .transition(reduceMotion ? .opacity : .asymmetric(
                insertion: .opacity.combined(with: .offset(y: 6)),
                removal: .opacity
            ))
    }
}

struct SearchThreadLink: View {
    let thread: AtlasAiThread
    let reduceMotion: Bool
    var newBadgeSuppressed: Bool = false

    var body: some View {
        threadLinkTransition(threadNavigationLink)
    }
}

extension SearchThreadLink {
    static func spokenLabel(_ thread: AtlasAiThread) -> String {
        var parts = [thread.title, "\(thread.messageCount) mensagens"]
        if TurnPresence.shared.runningTitles.contains(thread.title) {
            parts.append("executando")
        } else if ConversationModel.hasNewerContent(thread) {
            parts.append("novo desde a última visita")
        }
        return parts.joined(separator: ", ")
    }
}

extension SearchView {
    var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                listShellContent
            }
            .padding(.bottom, 40)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: trimmedQuery)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: session.threads.map(\.id))
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .refreshable { await session.loadThreads() }
    }
}

extension SearchView {
    @ViewBuilder
    var listQueryContent: some View {
        if isBrowsingRecent {
            if !recentThreads.isEmpty {
                SearchRecentSection(threads: recentThreads, reduceMotion: reduceMotion)
            }
        } else if searchResults.isEmpty {
            SearchMissEmpty(query: trimmedQuery, loadedThreadCount: session.threads.count)
        } else {
            SearchResultsSection(results: searchResults, query: trimmedQuery, reduceMotion: reduceMotion)
        }
    }
}

extension SearchView {
    @ViewBuilder
    var searchLoadingShell: some View {
        WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
            .accessibilityIdentifier(A11yID.searchLoading)
    }
}

extension SearchView {
    @ViewBuilder
    var searchOfflineShell: some View {
        AtlasNetworkFailureEmpty(
            kind: session.failureKind,
            hasToken: session.hasToken,
            host: session.host,
            topPadding: 56,
            retryHint: "reconecta e recarrega conversas para buscar",
            accessibilityIdentifier: A11yID.searchOffline,
            onRetry: { Task { await session.loadThreads() } }
        )
    }
}

extension SearchView {
    @ViewBuilder
    var listShellContent: some View {
        if showsLoadingShell {
            searchLoadingShell
        } else if showsNetworkFailure {
            searchOfflineShell
        } else {
            listQueryContent
        }
    }
}

extension SearchRecentSection {
    /// Mesma régua da lista de Conversas: saturado silencia em bloco.
    var newBadgeSaturated: Bool {
        threads.count >= 6
            && threads.lazy.filter(ConversationModel.hasNewerContent).count * 2 > threads.count
    }

    @ViewBuilder
    var recentThreadLoop: some View {
        let saturated = newBadgeSaturated
        ForEach(threads) { t in
            SearchThreadLink(thread: t, reduceMotion: reduceMotion, newBadgeSuppressed: saturated)
            if t.id != threads.last?.id {
                Divider().overlay(AtlasTheme.separator)
                    .padding(.leading, AtlasTheme.Space.screen + 36)
            }
        }
    }
}

struct SearchRecentSection: View {
    let threads: [AtlasAiThread]
    let reduceMotion: Bool

    var body: some View {
        Group {
            recentCaption
            recentThreadLoop
        }
    }
}

extension SearchRecentSection {
    var recentCaption: some View {
        Text("Recentes")
            .font(AtlasFont.mono(10, .semibold)).tracking(0.6)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("Recentes, \(threads.count) conversa\(threads.count == 1 ? "" : "s") carregada\(threads.count == 1 ? "" : "s")")
            .accessibilityIdentifier(A11yID.searchRecentCaption)
    }
}


// Cycle 044 fuse → WorkspaceView.swift

// Dentro de um workspace (repo): as conversas dele, com filtro de área no topo
// (Tudo / Operacional / Autônomos / Programação). Título em Fraunces serif.
// Vazio ≠ offline: falha de rede usa a mesma voz da home (`AtlasFailureCopy`).
// Chrome: +Chrome · lista: +Scroll · spoken: +A11y · empty: WorkspaceEmptyStates
struct WorkspaceView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let workspaceKey: String?
    let title: String
    /// Modo sem projeto: só conversas com workspace nulo (perguntas, pesquisas,
    /// pensamento livre — o uso GPT-no-iPhone). O projeto é opcional, não regra.
    var freeOnly: Bool = false
    @State var area: AtlasArea = .tudo

    var body: some View {
        workspaceScreenChrome(workspaceBodyStack)
    }
}

extension WorkspaceView {
    var workspaceBodyStack: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                if !showsNetworkFailure && !showsLoadingShell && hasThreadsToFilter {
                    areaFilter
                }
                listView
            }
            if !showsNetworkFailure && !showsLoadingShell {
                newPill
            }
        }
    }
}

extension WorkspaceView {
    func workspaceScreenChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(A11yID.workspaceScreen)
            // Contain without fused screen label so filter/list/pill stay focusable.
            .accessibilityElement(children: .contain)
    }
}

extension WorkspaceView {
    var areaFilterChipRow: some View {
        HStack(spacing: 8) {
            ForEach(AtlasArea.allCases) { a in
                areaFilterChip(a, active: a == area)
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
    }
}

extension WorkspaceView {
    var areaFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            areaFilterChipRow
        }
        .padding(.vertical, 10)
        .accessibilityIdentifier(A11yID.workspaceAreaFilter)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
    }
}

extension WorkspaceView {
    func areaFilterChip(_ a: AtlasArea, active: Bool) -> some View {
        Button {
            guard area != a else { return }
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            if reduceMotion {
                area = a
            } else {
                withAnimation(AtlasMotion.editorial) { area = a }
            }
        } label: {
            areaFilterChipLabel(a, active: active)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("área \(a.label)")
        .accessibilityHint("filtra conversas já carregadas")
        .accessibilityAddTraits(active ? [.isButton, .isSelected] : .isButton)
    }
}

extension WorkspaceView {
    func areaFilterChipLabel(_ a: AtlasArea, active: Bool) -> some View {
        Text(a.label)
            .font(active ? AtlasFont.serif(14, .semibold) : AtlasFont.serif(14))
            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textSecondary)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .frame(minHeight: 48) // HIG 44+; match primary filter breath
            .contentShape(Capsule())
            .background(
                Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface)
                    .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
            )
    }
}

extension WorkspaceView {
    var newPill: some View {
        NavigationLink(value: Route.new(workspaceKey: freeOnly ? nil : workspaceKey)) {
            newPillLabel
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            // Soft: workspace write pill is invitation (AgenticPill class).
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
        })
        .accessibilityLabel("nova conversa")
        .accessibilityHint("abre o compositor para escrever ao Atlas")
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(10) // primary write pill surfaces early in VO
        .accessibilityIdentifier(A11yID.workspaceNewPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

extension WorkspaceView {
    // Mesma pílula agêntica da home: ✦ ouro + vidro (padrão §6). Sem mic —
    // voz está fora EM DEFINITIVO (canon §6).
    var newPillLabel: some View {
        HStack(spacing: 12) {
            Text("✦").font(AtlasFont.serif(16))
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)
            Text("Escreva ao Atlas")
                .font(AtlasFont.serifItalic(17))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(minHeight: 52) // match AgenticPill invite breath
        .contentShape(Capsule())
        .atlasGlassCapsule()
    }
}

extension WorkspaceThreadsSection {
    var caption: String {
        if area == .tudo {
            return "\(threads.count) conversa\(threads.count == 1 ? "" : "s")"
        }
        return "\(threads.count) em \(area.label)"
    }
}

extension WorkspaceThreadsSection {
    var spokenCaption: String {
        if area == .tudo {
            return "\(threads.count) conversa\(threads.count == 1 ? "" : "s") em \(screenTitle)"
        }
        return "\(threads.count) conversa\(threads.count == 1 ? "" : "s") em \(area.label), \(screenTitle)"
    }
}

extension WorkspaceThreadsSection {
    var captionHeader: some View {
        Text(spokenCaption)
            .font(AtlasFont.serif(13, .semibold))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(spokenCaption)
            .accessibilityIdentifier(A11yID.workspaceThreadsCaption)
    }
}

extension WorkspaceView {
    var showsLoadingShell: Bool {
        guard session.threads.isEmpty else { return false }
        switch session.phase {
        case .idle, .loading: return true
        default: return false
        }
    }
}

extension WorkspaceView {
    var showsNetworkFailure: Bool {
        guard session.threads.isEmpty else { return false }
        if case .failed = session.phase { return true }
        return false
    }
}

extension WorkspaceView {
    var listView: some View {
        ScrollView {
            workspaceListChrome(
                LazyVStack(spacing: 0) {
                    scrollPhaseContent
                }
            )
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }
}

extension WorkspaceView {
    func workspaceListChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.bottom, 96)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: threads.map(\.id))
    }
}

extension WorkspaceView {
    var listNetworkFailure: some View {
        AtlasNetworkFailureEmpty(
            kind: session.failureKind,
            hasToken: session.hasToken,
            host: session.host,
            retryHint: "reconecta e recarrega conversas deste workspace",
            retryAccessibilityIdentifier: A11yID.workspaceRetry,
            accessibilityIdentifier: A11yID.workspaceOffline,
            onRetry: { Task { await session.loadThreads() } }
        )
    }
}

extension WorkspaceView {
    @ViewBuilder
    var listLoadedContent: some View {
        if threads.isEmpty {
            WorkspaceEditorialEmpty(area: area, freeOnly: freeOnly, screenTitle: title)
        } else {
            WorkspaceThreadsSection(
                threads: threads,
                area: area,
                screenTitle: title,
                reduceMotion: reduceMotion
            )
        }
    }
}

extension WorkspaceView {
    @ViewBuilder
    var scrollPhaseContent: some View {
        if showsLoadingShell {
            WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
                .accessibilityIdentifier(A11yID.workspaceLoading)
        } else if showsNetworkFailure {
            listNetworkFailure
        } else {
            listLoadedContent
        }
    }
}

struct WorkspaceThreadLink: View {
    let thread: AtlasAiThread
    let reduceMotion: Bool
    var newBadgeSuppressed: Bool = false

    var body: some View {
        threadLinkA11y
    }
}

extension WorkspaceThreadLink {
    var threadLinkA11y: some View {
        NavigationLink(value: Route.thread(id: ThreadID(thread.id), title: thread.title)) {
            ThreadRow(thread: thread, newBadgeSuppressed: newBadgeSuppressed, ownsAccessibility: false)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
        })
        .accessibilityLabel(SearchThreadLink.spokenLabel(thread))
        .accessibilityHint(
            TurnPresence.shared.runningTitles.contains(thread.title)
                ? "Atlas executando nesta conversa"
                : "abre a conversa"
        )
        .accessibilityAddTraits(
            TurnPresence.shared.runningTitles.contains(thread.title) && !reduceMotion
                ? [.isButton, .updatesFrequently]
                : .isButton
        )
        .accessibilityIdentifier(A11yID.workspaceThread(thread.id))
        .transition(threadTransition)
    }
}

extension WorkspaceThreadLink {
    var threadTransition: AnyTransition {
        reduceMotion ? .opacity : .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 6)),
            removal: .opacity
        )
    }
}

extension WorkspaceView {
    var threads: [AtlasAiThread] {
        let base = freeOnly
            ? session.threads.filter { $0.workspace == nil }
            : session.threads(inWorkspace: workspaceKey)
        return area == .tudo ? base : base.filter { AtlasArea.of($0) == area }
    }

    /// Filtro só existe quando há o que filtrar: chips numa lista vazia
    /// são ruído (regra da casa: controle sem efeito não aparece).
    var hasThreadsToFilter: Bool {
        freeOnly
            ? session.threads.contains { $0.workspace == nil }
            : !session.threads(inWorkspace: workspaceKey).isEmpty
    }
}

extension WorkspaceView {
    var header: some View {
        HStack(spacing: 12) {
            headerBackButton
            Spacer()
            Text(title)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityLabel(headerSpokenTitle)
            Spacer()
            Color.clear.frame(width: 48, height: 48)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    var headerBackButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 48, height: 48).atlasGlassCircle()
                .contentShape(Circle())
        }
        .accessibilityLabel("voltar")
        .accessibilityHint("fecha o workspace")
    }

    var headerSpokenTitle: String {
        if freeOnly { return "conversas sem projeto" }
        return title
    }
}

extension WorkspaceThreadsSection {
    @ViewBuilder
    func threadRowLoop(_ t: AtlasAiThread, newBadgeSuppressed: Bool = false) -> some View {
        WorkspaceThreadLink(thread: t, reduceMotion: reduceMotion, newBadgeSuppressed: newBadgeSuppressed)
        threadRowSeparator(after: t)
    }
}

extension WorkspaceThreadsSection {
    @ViewBuilder
    func threadRowSeparator(after thread: AtlasAiThread) -> some View {
        if thread.id != threads.last?.id {
            Divider().overlay(AtlasTheme.separator)
                .padding(.leading, AtlasTheme.Space.screen + 36)
        }
    }
}

extension WorkspaceThreadsSection {
    /// Badge "novo" saturado (maioria de 6+ linhas) perde o poder de
    /// discriminar — silencia em bloco; a ordenação já diz recência.
    var newBadgeSaturated: Bool {
        threads.count >= 6
            && threads.lazy.filter(ConversationModel.hasNewerContent).count * 2 > threads.count
    }

    @ViewBuilder
    var threadRows: some View {
        let saturated = newBadgeSaturated
        ForEach(threads) { t in
            threadRowLoop(t, newBadgeSuppressed: saturated)
        }
    }
}

struct WorkspaceThreadsSection: View {
    let threads: [AtlasAiThread]
    let area: AtlasArea
    let screenTitle: String
    let reduceMotion: Bool

    var body: some View {
        Group {
            captionHeader
            threadRows
        }
    }
}


// Cycle 044 fuse → WorkspaceEmptyStates.swift

// Estados vazios do WorkspaceView (offline) —

/// Falha de rede compartilhada — home, workspace e conversa (voz via `AtlasFailureCopy`).
struct AtlasNetworkFailureEmpty: View {
    let kind: AtlasNetworkFailureKind?
    let hasToken: Bool
    let host: String
    var topPadding: CGFloat = 56
    var retryHint: String = "reconecta ao servidor Atlas"
    var retryAccessibilityIdentifier: String?
    let accessibilityIdentifier: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        failureChrome(failureCopyBlock)
    }
}

extension WorkspaceEditorialEmpty {
    var editorialFootnote: String {
        if freeOnly {
            return "perguntas e pensamento livre começam abaixo"
        }
        return "comece uma abaixo — o projeto é opcional"
    }
}

extension WorkspaceEditorialEmpty {
    var editorialHeadline: String {
        if area != .tudo {
            return "“Nada em \(area.label) — por enquanto.”"
        }
        if freeOnly {
            return "“Nenhuma conversa sem projeto ainda.”"
        }
        return "“Nenhuma conversa em \(screenTitle) ainda.”"
    }
}

extension WorkspaceEditorialEmpty {
    var headline: String { editorialHeadline }
    var footnote: String { editorialFootnote }
}

/// ✦ + headline editorial compartilhado — workspace vazio e search miss.
struct AtlasEditorialGlyphEmpty: View {
    let headline: String
    var footnote: String? = nil
    let accessibilityIdentifier: String
    var spokenLabel: String? = nil

    var body: some View {
        editorialStack
            .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLabel ?? headline)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}

extension WorkspaceEditorialEmpty {
    var spokenLabel: String {
        let lead: String
        if area != .tudo {
            lead = "nada em \(area.label) em \(screenTitle)"
        } else if freeOnly {
            lead = "Nenhuma conversa sem projeto ainda"
        } else {
            lead = "nenhuma conversa em \(screenTitle) ainda"
        }
        return "\(lead). \(footnote)"
    }
}

extension AtlasEditorialGlyphEmpty {
    var editorialCopyStack: some View {
        VStack(spacing: 8) {
            Text(headline)
                .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            if let footnote {
                Text(footnote)
                    .font(AtlasFont.serif(13)).foregroundStyle(AtlasTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension AtlasEditorialGlyphEmpty {
    var editorialGlyph: some View {
        Text("✦")
            .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
            .accessibilityHidden(true)
    }
}

extension AtlasEditorialGlyphEmpty {
    var editorialStack: some View {
        VStack(spacing: 14) {
            editorialGlyph
            editorialCopyStack
        }
    }
}

struct WorkspaceEditorialEmpty: View {
    let area: AtlasArea
    let freeOnly: Bool
    let screenTitle: String

    var body: some View {
        editorialGlyph
    }
}

extension AtlasNetworkFailureEmpty {
    @ViewBuilder
    func retryButtonWithIdentifier<Content: View>(_ button: Content) -> some View {
        if let retryAccessibilityIdentifier {
            button.accessibilityIdentifier(retryAccessibilityIdentifier)
        } else {
            button
        }
    }
}

extension AtlasNetworkFailureEmpty {
    @ViewBuilder
    var retryButton: some View {
        retryButtonWithIdentifier(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry()
            } label: {
                retryLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("tentar de novo")
            .accessibilityHint(retryHint)
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(8)
        )
    }
}

extension AtlasNetworkFailureEmpty {
    func failureChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 44).padding(.top, topPadding)
            .frame(maxWidth: .infinity)
            // Contain without container label so retry stays focusable.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}

extension WorkspaceEditorialEmpty {
    var editorialGlyph: some View {
        AtlasEditorialGlyphEmpty(
            headline: headline,
            footnote: footnote,
            accessibilityIdentifier: A11yID.workspaceEmpty,
            spokenLabel: spokenLabel
        )
    }
}

extension AtlasNetworkFailureEmpty {
    var failureCopyBlock: some View {
        VStack(spacing: 0) {
            failureCopyText
            if hasToken {
                Spacer().frame(height: 28)
                retryButton
            }
        }
    }
}

extension AtlasNetworkFailureEmpty {
    var failureCopyText: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(28)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
            Spacer().frame(height: 28)
            Text(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken))
                .font(AtlasFont.serif(22, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Spacer().frame(height: 12)
            failureHostAndHint
        }
    }
}

extension AtlasNetworkFailureEmpty {
    var failureHostAndHint: some View {
        Group {
            Text(hasToken ? "\(host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(hasToken ? "servidor \(host) porta 3737" : "token ATLAS ausente em Secrets")
            Spacer().frame(height: 16)
            Text(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))
                .font(AtlasFont.serif(14)).lineSpacing(5)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct WorkspaceLoadingEmpty: View {
    var reduceMotion: Bool
    var text: String = "abrindo conversas…"
    var spoken: String? = nil
    var topPadding: CGFloat = 72

    var body: some View {
        VStack(spacing: 18) {
            BreathingGlyph(reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity).padding(.top, topPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken ?? text)
        .accessibilityAddTraits(.isHeader)
    }
}

extension AtlasNetworkFailureEmpty {
    var retryLabel: some View {
        Text("Tentar de novo")
            .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.accent)
            .padding(.horizontal, 22).padding(.vertical, 12)
            .frame(minHeight: 48) // match primary CTA breath
            .background(Capsule().fill(AtlasTheme.goldVeil)
                .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
            .contentShape(Capsule())
    }
}


// Cycle 044 fuse → RootChrome.swift

// Presentation-only chrome shared by RootView / WorkspaceView / SearchView.
// Route + navigation stay in RootView.
// Rows: RootChrome+Rows.swift · Controls: RootChrome+Controls.swift
// A11y: RootChrome+SectionA11y.swift

/// Label de seção da home (Conversas / Operação / Workspaces) — natural-case visual + VO.
@MainActor
func sectionLabel(_ t: String, accessibilityID: String? = nil) -> some View {
    // A linha premium do site: hairlines em fade ladeando o rótulo natural.
    let spoken = sectionSpokenLabel(t)
    return HStack(spacing: 12) {
        LinearGradient(colors: [AtlasTheme.separator.opacity(0), AtlasTheme.separator],
                       startPoint: .leading, endPoint: .trailing)
            .frame(height: 1)
        Text(spoken)
            .font(AtlasFont.serif(13, .semibold))
            .foregroundStyle(AtlasTheme.textTertiary)
            .fixedSize()
        LinearGradient(colors: [AtlasTheme.separator, AtlasTheme.separator.opacity(0)],
                       startPoint: .leading, endPoint: .trailing)
            .frame(height: 1)
    }
    .padding(.horizontal, AtlasTheme.Space.screen)
    .padding(.top, 18)
    .padding(.bottom, 11)
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(.isHeader)
    .accessibilityLabel(spoken)
    .homeSectionA11yID(accessibilityID)
}

/// Canonical natural Portuguese for home section headers (accepts legacy UPPERCASE).
private func sectionSpokenLabel(_ t: String) -> String {
    switch t.uppercased() {
    case "CONVERSAS": return "Conversas"
    case "OPERAÇÃO", "OPERACAO": return "Operação"
    case "WORKSPACES": return "Workspaces"
    default: return t
    }
}

/// O ✦ respirando — a marca viva do Atlas nos estados de espera.
struct BreathingGlyph: View {
    let reduceMotion: Bool
    @State var on = false
    var body: some View {
        Text("✦")
            .font(AtlasFont.serif(30)).foregroundStyle(AtlasTheme.accent)
            .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
            .scaleEffect(on ? 1.08 : 1).opacity(on ? 0.8 : 1)
            .onAppear {
                if !reduceMotion {
                    withAnimation(AtlasMotion.breath(1.6)) { on = true }
                }
            }
            .accessibilityHidden(true)
    }
}

extension View {
    func homeSectionA11yID(_ id: String?) -> some View {
        atlasAccessibilityIdentifier(id)
    }
}

extension CircleButton {
    var circleButtonLabel: some View {
        Image(systemName: icon)
            .atlasSans(16, .medium).foregroundStyle(AtlasTheme.textSecondary)
            .frame(width: 48, height: 48).atlasGlassCircle()
            .overlay(alignment: .topTrailing) {
                badgeOverlay
            }
    }
}

struct CircleButton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let icon: String
    /// Ponto de exceção: só aparece quando existe algo que fala. Silêncio é o
    /// estado normal — o botão não carrega contador decorativo.
    var badge: Bool = false
    let action: () -> Void
    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            circleButtonLabel
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityAddTraits(.isButton)
    }
}

extension CircleButton {
    @ViewBuilder
    var badgeOverlay: some View {
        if badge {
            Circle()
                .fill(AtlasCodePalette.alert)
                .frame(width: 9, height: 9)
                .overlay(Circle().strokeBorder(AtlasTheme.bg, lineWidth: 1.5))
                .offset(x: 1, y: -1)
                .accessibilityHidden(true)
        }
    }
}

/// Contagem zero = «nenhuma conversa»; badge só quando o model marca atenção real.

enum RootChromeRowA11y {
    static func workspaceSpoken(
        name: String,
        count: Int?,
        detail: String?,
        badge: Bool
    ) -> String {
        var parts = [name]
        if let count {
            parts.append(workspaceCountPart(count))
        }
        parts.append(contentsOf: workspaceDetailParts(detail: detail, badge: badge))
        return parts.joined(separator: ", ")
    }
}

extension RootChromeRowA11y {
    static func workspaceCountPart(_ count: Int) -> String {
        if count == 0 {
            return "nenhuma conversa"
        }
        return "\(count) conversa\(count == 1 ? "" : "s")"
    }
}

extension RootChromeRowA11y {
    static func workspaceDetailParts(detail: String?, badge: Bool) -> [String] {
        var parts: [String] = []
        if let detail, !detail.isEmpty {
            parts.append(detail)
        }
        if badge {
            parts.append("atenção necessária")
        }
        return parts
    }
}

extension RootChromeRowA11y {
    static func threadSpoken(
        title: String,
        messageCount: Int,
        isRunning: Bool,
        isNew: Bool,
        hasWorkspace: Bool
    ) -> String {
        var parts = [title]
        parts.append(contentsOf: threadStatusParts(
            messageCount: messageCount,
            isRunning: isRunning,
            isNew: isNew,
            hasWorkspace: hasWorkspace
        ))
        return parts.joined(separator: ", ")
    }
}

extension RootChromeRowA11y {
    static func spokenThreadMessageCount(_ messageCount: Int) -> [String] {
        if messageCount == 0 {
            return ["nenhuma mensagem"]
        }
        return ["\(messageCount) mensagem\(messageCount == 1 ? "" : "ns")"]
    }
}

extension RootChromeRowA11y {
    static func threadHint(isRunning: Bool) -> String {
        isRunning ? "Atlas executando nesta conversa" : "abre a conversa"
    }
}

extension RootChromeRowA11y {
    static func threadMessageParts(messageCount: Int, isRunning: Bool) -> [String] {
        if isRunning { return spokenThreadRunning() }
        return spokenThreadMessageCount(messageCount)
    }
}

extension RootChromeRowA11y {
    static func spokenThreadRunning() -> [String] {
        ["Atlas executando"]
    }
}

extension RootChromeRowA11y {
    static func threadStatusParts(
        messageCount: Int,
        isRunning: Bool,
        isNew: Bool,
        hasWorkspace: Bool
    ) -> [String] {
        var parts = threadMessageParts(messageCount: messageCount, isRunning: isRunning)
        if isNew && !isRunning {
            parts.append("novo desde a última visita")
        }
        if hasWorkspace {
            parts.append("com workspace")
        }
        return parts
    }
}

struct WorkspaceRow: View {
    let icon: String
    let name: String
    let count: Int?
    var detail: String?
    var badge: Bool = false
    /// Voz/identidade vivem NO botão: rotular por fora cria um invólucro
    /// `Other` mudo por cima e apaga o botão para VoiceOver e XCUITest.
    var a11yID: String?
    var spokenOverride: String?
    var spokenHint: String?
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            rowContent
        }
        .buttonStyle(.plain)
        // Sem accessibilityElement(children:) aqui: Button JÁ é elemento de
        // a11y; recriar o elemento gera um invólucro `Other` e emudece o botão.
        .accessibilityLabel(spokenOverride ?? RootChromeRowA11y.workspaceSpoken(name: name, count: count, detail: detail, badge: badge))
        .accessibilityHint(spokenHint ?? "abre \(name)")
        .atlasAccessibilityIdentifier(a11yID)
        .accessibilityAddTraits(.isButton)
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var workspaceRowLeadingStack: some View {
        workspaceRowLeading
        workspaceRowNameStack
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var workspaceRowTrailingStack: some View {
        Spacer(minLength: 8)
        rowTrailing
    }
}

extension WorkspaceRow {
    var workspaceRowHBox: some View {
        HStack(spacing: 14) {
            workspaceRowLeadingStack
            workspaceRowTrailingStack
        }
    }
}

extension WorkspaceRow {
    var workspaceRowLeading: some View {
        // Hierarchical: o SF ganha profundidade de dois tons (régua premium).
        Image(systemName: icon)
            .symbolRenderingMode(.hierarchical)
            .atlasSans(18).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
            .accessibilityHidden(true)
    }
}

extension WorkspaceRow {
    var workspaceRowNameStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(name)
                .font(AtlasFont.serif(16))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityHidden(true)
            rowDetail
        }
    }
}

extension WorkspaceRow {
    var rowContent: some View {
        workspaceRowHBox
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
            .frame(minHeight: 48, alignment: .center)
            .contentShape(Rectangle())
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowDetail: some View {
        // Voz calma: o ponto vermelho (badge) é o único alerta da linha —
        // texto em vermelho por cima dele era sinal duplicado gritando.
        if let detail, !detail.isEmpty {
            Text(detail)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailing: some View {
        rowTrailingBadge
        rowTrailingCount
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailingBadge: some View {
        if badge {
            Circle()
                .fill(AtlasTheme.alert)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
        }
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailingCount: some View {
        if let count {
            // Número é meta: mono editorial quieto (ausência = ausência).
            Text("\(count)")
                .font(AtlasFont.mono(12, .medium))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
        Image(systemName: "chevron.right")
            .atlasSans(11, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.55))
            .accessibilityHidden(true)
    }
}

extension ThreadRow {
    func threadA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                RootChromeRowA11y.threadSpoken(
                    title: thread.title,
                    messageCount: thread.messageCount,
                    isRunning: isRunning,
                    isNew: isNew,
                    hasWorkspace: workspaceTint != nil
                )
            )
            .accessibilityHint(RootChromeRowA11y.threadHint(isRunning: isRunning))
            // Running rows re-speak presence; Reduce Motion keeps static copy.
            .accessibilityAddTraits(
                isRunning && !reduceMotion
                    ? [.isButton, .updatesFrequently]
                    : .isButton
            )
    }
}

extension ThreadRow {
    var rowContent: some View {
        HStack(spacing: 14) {
            rowLead
            Text(thread.title)
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1).truncationMode(.tail)
                .accessibilityHidden(true)
            Spacer(minLength: 8)
            rowTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .frame(minHeight: 48, alignment: .center)
        .overlay(alignment: .leading) { rowWorkspaceTint }
        .contentShape(Rectangle())
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowLead: some View {
        if isRunning {
            BreathingDiamond(size: 9, reduceMotion: reduceMotion).frame(width: 22)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "bubble.left")
                .atlasSans(17).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                .accessibilityHidden(true)
        }
    }
}

extension ThreadRow {
    @ViewBuilder
    var newThreadBadge: some View {
        if isNew && !isRunning {
            Text("Novo")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Capsule().fill(AtlasTheme.goldVeil))
                .accessibilityHidden(true)
        }
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowWorkspaceTint: some View {
        if let workspaceTint {
            Rectangle()
                .fill(workspaceTint.opacity(0.85))
                .frame(width: 2)
                .padding(.vertical, 10)
                .accessibilityHidden(true)
        }
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowTrailing: some View {
        rowTrailingStatus
        Image(systemName: "chevron.right")
            .atlasSans(13, .semibold).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension ThreadRow {
    var rowTrailingCount: some View {
        Text("\(thread.messageCount)")
            .atlasSans(16)
            .foregroundStyle(AtlasTheme.textTertiary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityHidden(true)
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowTrailingRunning: some View {
        Text("Executando").font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowTrailingStatus: some View {
        newThreadBadge
        if isRunning {
            rowTrailingRunning
        } else {
            rowTrailingCount
        }
    }
}

// Linha de conversa — compartilhada com Search/Workspace. Hub vivo: turno
// executando troca ícone por losango e contador por "executando".

struct ThreadRow: View {
    let thread: AtlasAiThread
    /// Sinal saturado não discrimina: quando a maioria da lista seria "novo",
    /// o dono da lista silencia o badge em bloco (volta quando for exceção).
    var newBadgeSuppressed: Bool = false
    /// When false, a parent NavigationLink owns VO label/traits (Search/Workspace).
    var ownsAccessibility: Bool = true
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isRunning: Bool { TurnPresence.shared.runningTitles.contains(thread.title) }
    var isNew: Bool { !newBadgeSuppressed && ConversationModel.hasNewerContent(thread) }
    var workspaceTint: Color? { thread.workspace.map(threadWorkspaceColor) }

    var body: some View {
        if ownsAccessibility {
            threadA11yChrome(rowContent)
        } else {
            rowContent
        }
    }
}

func threadWorkspaceColor(_ workspace: String) -> Color {
    let palette = [AtlasTheme.accent, AtlasTheme.prussian, AtlasTheme.domAutonomos, AtlasTheme.domOperacional]
    let total = workspace.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    return palette[abs(total) % palette.count]
}


/// Chrome único da pílula agêntica (baseline Home craft).
/// Só mudam: `invite`, `action`, `accessibilityIdentifier` / hint.
/// Pack nunca na cara — só viaja em `turnFacts`.
struct AgenticPill: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let invite: String
    var accessibilityId: String = A11yID.arenaPremiumAskPill
    var accessibilityHintText: String = "Abre conversa com o contexto desta tela"
    let action: () -> Void

    var body: some View {
        Button(action: {
            // Soft impact: pílula is invitation, not commit.
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        }) {
            HStack(spacing: 12) {
                RootView.HomeComposerStar()
                Text(invite)
                    .font(AtlasFont.serifItalic(17))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(minHeight: 52) // HIG 44+; calmer invite touch
            // Vidro no background do label — glassEffect.interactive no iOS 26
            // aplicado como modifier de conteúdo às vezes engole o identifier.
            .background { Capsule().fill(AtlasTheme.bgRecessed.opacity(0.01)) }
            .atlasGlassCapsule()
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                AtlasTheme.accent.opacity(0.26),
                                AtlasTheme.accent.opacity(0.05),
                                AtlasTheme.accent.opacity(0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
                    )
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(invite)
        .atlasAccessibilityHint(accessibilityHintText)
        .accessibilityIdentifier(accessibilityId)
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(8) // chrome único da pílula — cedo no rotor
    }
}

/// Compat: call sites antigos Arena/Autônomos.
typealias ArenaPremiumAskPill = AgenticPill


// Cycle 044 fuse → AtlasProfileSheet.swift

// Perfil do operador — sheet da home (ordem do operador 2026-07-18:
// "no botão de perfil cria uma tela, ultra premium e padronizada").
// Sheet = profundidade da home, não rota nova (canon §6 intacto).

struct AtlasProfileSheet: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    profileMasthead
                    profileRows
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 18)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AtlasCloseToolbarButton(
                        spokenLabel: "fechar perfil",
                        spokenHint: "volta para a home",
                        accessibilityID: A11yID.profileSheet + "-close",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
            }
            .accessibilityIdentifier(A11yID.profileSheet)
            // Contain: masthead, rows and audit toggle stay separately focusable.
            .accessibilityElement(children: .contain)
        }
    }

    private var profileMasthead: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.fill")
                .atlasSans(26)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 72, height: 72)
                .atlasGlassCircle()
                .accessibilityHidden(true)
            Text("Vitor")
                .font(AtlasFont.serif(24, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Operador do Atlas")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Vitor, operador do Atlas")
    }
}

extension AtlasProfileSheet {
    @ViewBuilder
    var profileRows: some View {
        @Bindable var session = session

        VStack(spacing: 0) {
            profileLine("Servidor", value: session.host, mono: true)
            Divider().overlay(AtlasTheme.separatorSoft)
            profileLine("Estado", value: connectionLabel)
            Divider().overlay(AtlasTheme.separatorSoft)
            profileLine("Conversas", value: "\(session.threads.count)")
            Divider().overlay(AtlasTheme.separatorSoft)
            profileLine("Workspaces", value: "\(session.workspaces.count)")
        }
        .atlasCard()

        Toggle(isOn: $session.auditModeEnabled) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Modo auditoria")
                    .font(AtlasFont.serif(15, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("Mostra detalhes técnicos nas telas")
                    .font(AtlasFont.serif(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .tint(AtlasTheme.accent)
        .padding(.horizontal, 14).padding(.vertical, 12)
        .frame(minHeight: 56)
        .frame(minHeight: 48, alignment: .center)
        .atlasCard()
        .onChange(of: session.auditModeEnabled) { _, _ in
            // Soft: audit chrome is presentation preference, not governed commit.
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
        }
        .accessibilityIdentifier(A11yID.profileAuditToggle)
        .accessibilityLabel("Modo auditoria")
        .accessibilityHint("mostra ou oculta detalhes técnicos nas telas")

        Text("Atlas \(appVersion)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.top, 8)
    }

    private func profileLine(_ label: String, value: String, mono: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.textSecondary)
            Spacer()
            if mono {
                Text(value).font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            } else {
                Text(value)
                    .font(AtlasFont.serif(15))
                    .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .frame(minHeight: 48)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value)")
    }

    var connectionLabel: String {
        if session.failureKind != nil { return "fora de alcance" }
        if case .loaded = session.phase { return "conectado" }
        return "conectando…"
    }

    var appVersion: String {
        let info = Bundle.main.infoDictionary ?? [:]
        let v = info["CFBundleShortVersionString"] as? String ?? "?"
        let b = info["CFBundleVersion"] as? String ?? "?"
        return "\(v) (\(b))"
    }
}


// Cycle 044 fuse → AtlasWorkspace.swift

struct Workspace: Identifiable, Hashable {
    let id: String     // chave = nome de pasta minúsculo
    let name: String   // exibição
    let count: Int
}

// Área/modo de uma conversa. Heurística por surface + metadata (o dado de modo é
// esparso hoje; conforme o servidor popular current_mode/routing_domain, afina).
enum AtlasArea: String, CaseIterable, Identifiable {
    case tudo, operacional, autonomos, programacao
    var id: String { rawValue }

    var labelDomain: String? {
        switch self {
        case .operacional: return "Operacional"
        case .autonomos: return "Autônomos"
        case .programacao: return "Programação"
        default: return nil
        }
    }

    var label: String {
        labelDomain ?? "Tudo"
    }

    static func of(_ t: AtlasAiThread) -> AtlasArea {
        let surface = t.surface.lowercased()
        let mode = (t.metadata?["current_mode"]?.stringValue
            ?? t.metadata?["atlas_mode"]?.stringValue
            ?? t.metadata?["workflow_mode"]?.stringValue ?? "").lowercased()
        let domain = (t.metadata?["routing_domain"]?.stringValue ?? "").lowercased()
        if surface.contains("code") || domain.contains("eng") || domain.contains("prog") || mode.contains("program") {
            return .programacao
        }
        if mode.contains("auto") || mode.contains("loop") || (t.metadata?["awis_automation"]?.boolValue ?? false) {
            return .autonomos
        }
        return .operacional
    }
}

extension AtlasWorkspacePickerSheet {
    /// Todos os repos reais do Mac, sem duplicata, por RECÊNCIA (último commit
    /// primeiro; sem história vai ao fim, em ordem alfabética), filtrados pela busca.
    var pickerRepos: [AtlasCodeRepoRef] {
        guard let ws = model.workspace else { return [] }
        var seen = Set<String>()
        let all = (ws.folders.flatMap(\.repos) + ws.loose + ws.recents)
            .filter { seen.insert($0.slug).inserted }
            .sorted { a, b in
                switch (a.lastCommitAt, b.lastCommitAt) {
                case let (x?, y?): return x > y
                case (_?, nil): return true
                case (nil, _?): return false
                case (nil, nil): return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
                }
            }
        guard !query.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(query)
            || ($0.folder?.localizedCaseInsensitiveContains(query) ?? false) }
    }

    /// "Sem repositório": conversa geral com o Atlas — pesquisa, ideias, nada
    /// preso a um projeto. É o que o antigo "+" fazia, agora nomeado.
    var noRepoRow: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onNoRepo?()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bubble.left")
                    .atlasSans(16)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 22)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sem repositório").atlasSans(16, .medium)
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("Conversar ou pesquisar, sem projeto").atlasSans(13)
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer()
                Image(systemName: "chevron.right").atlasSans(13, .semibold)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 14).padding(.vertical, 14)
            .frame(minHeight: 56)
            .contentShape(Rectangle())
            .atlasCard()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Sem repositório")
        .accessibilityHint("Conversa geral com o Atlas, sem projeto")
        .accessibilityIdentifier(A11yID.workspacePickerNoRepo)
        .accessibilityAddTraits(.isButton)
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 12)
    }

    var pickerRepoList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Repositórios")
                    .font(AtlasFont.mono(11, .medium)).tracking(0.6)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, showsNoRepoSpacing ? 18 : 4)
                VStack(spacing: 0) {
                    ForEach(pickerRepos) { repo in
                        pickerRepoRow(repo)
                        if repo.id != pickerRepos.last?.id {
                            Divider().overlay(AtlasTheme.separatorSoft)
                        }
                    }
                }
                .atlasCard()
                .padding(.horizontal, AtlasTheme.Space.screen)
            }
            .padding(.vertical, 12)
        }
    }

    private var showsNoRepoSpacing: Bool { onNoRepo != nil && query.isEmpty }

    private func pickerRepoRow(_ repo: AtlasCodeRepoRef) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onPick(repo.slug, repo.name)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "folder")
                    .atlasSans(15)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                HStack(spacing: 0) {
                    if let folder = repo.folder {
                        Text("\(folder)/").atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    Text(repo.name).atlasSans(15, .medium).foregroundStyle(AtlasTheme.textPrimary)
                }
                .lineLimit(1)
                Spacer()
                if let age = AtlasCodeAge.short(from: repo.lastCommitAt) {
                    Text(age).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(repo.folder.map { "\($0), " } ?? "")\(repo.name)")
        .accessibilityHint("abre o workspace deste repositório")
        .accessibilityIdentifier(A11yID.workspacePickerRow(repo.slug))
        .accessibilityAddTraits(.isButton)
    }
}

// Picker de workspace — sheet da home (referência Cursor, ordem 2026-07-18):
// busca + TODOS os repositórios reais do Mac (via AtlasCodeWorkspaceModel —
// a mesma fonte do radar; a casca não faz rede). Escolher abre o workspace.

struct AtlasWorkspacePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State var model: AtlasCodeWorkspaceModel
    @State var query = ""
    let title: String
    /// Opção "Sem repositório" (conversa geral com o Atlas). nil = não mostra.
    let onNoRepo: (() -> Void)?
    let onPick: (_ key: String, _ title: String) -> Void

    init(
        client: AtlasClient,
        title: String = "Adicionar workspace",
        onNoRepo: (() -> Void)? = nil,
        onPick: @escaping (_ key: String, _ title: String) -> Void
    ) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.title = title
        self.onNoRepo = onNoRepo
        self.onPick = onPick
    }

    private var showsNoRepo: Bool { onNoRepo != nil && query.isEmpty }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // "Sem repositório" é instantâneo — não depende do Mac
                // responder. Fica no topo; os repos carregam/rolam abaixo.
                if showsNoRepo { noRepoRow }
                pickerContent
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Buscar repositórios")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AtlasCloseToolbarButton(
                        spokenLabel: "fechar seletor de workspace",
                        spokenHint: "volta sem escolher repositório",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
            }
            .task { if case .idle = model.phase { await model.load() } }
            .accessibilityIdentifier(A11yID.workspacePickerSheet)
        }
    }

    @ViewBuilder
    private var pickerContent: some View {
        switch model.phase {
        case .idle, .loading:
            VStack(spacing: 12) {
                BreathingDiamond(size: 10, reduceMotion: reduceMotion)
                Text("Lendo os repositórios do Mac…")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Lendo os repositórios do Mac")
            .accessibilityAddTraits(reduceMotion ? .isStaticText : [.isStaticText, .updatesFrequently])
        case .failed:
            VStack(spacing: 10) {
                Text("O Mac não respondeu.")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    Task { await model.load() }
                } label: {
                    Text("Tentar de novo")
                        .atlasSans(15, .medium)
                        .foregroundStyle(AtlasTheme.accent)
                        .frame(minHeight: 48)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("tentar de novo")
                .accessibilityHint("relê os repositórios do Mac")
                .accessibilityAddTraits(.isButton)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        default:
            pickerRepoList
        }
    }
}
