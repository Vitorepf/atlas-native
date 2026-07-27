import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: RootChrome fused

// MARK: - RootChrome

// MARK: - Shared chrome helpers

@MainActor
@ViewBuilder
func sectionLabel(_ t: String, accessibilityID: String? = nil) -> some View {
    HStack(spacing: 12) {
        LinearGradient(colors: [AtlasTheme.separator.opacity(0), AtlasTheme.separator],
                       startPoint: .leading, endPoint: .trailing)
            .frame(height: 1)
        Text(t)
            .font(AtlasFont.mono(10, .semibold))
            .tracking(1.55)
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
    .homeSectionA11yID(accessibilityID)
}

private struct HomeSectionA11yID: ViewModifier {
    let id: String?
    func body(content: Content) -> some View {
        if let id {
            content.accessibilityIdentifier(id)
        } else {
            content
        }
    }
}

extension View {
    func homeSectionA11yID(_ id: String?) -> some View {
        modifier(HomeSectionA11yID(id: id))
    }
}

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
                    withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { on = true }
                }
            }
            .accessibilityHidden(true)
    }
}

struct CircleButton: View {
    let icon: String
    var badge: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .atlasSans(15, .medium).foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 44, height: 44).atlasGlassCircle()
                .overlay(alignment: .topTrailing) {
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
        .accessibilityAddTraits(.isButton)
    }
}

/// Identidade visual do workspace — NÃO é estado.
///
/// A paleta antiga sorteava entre `accent` (ouro = estado/marca),
/// `domAutonomos` (verde = domínio Autônomos) e `domOperacional` (bronze =
/// domínio Operacional). Como a escolha é um hash do nome, uma conversa do
/// `repo` ganhava trilho verde e lia como se fosse dos Autônomos. Estes quatro
/// tons frios não significam nada em outro lugar do app: só agrupam.
func threadWorkspaceColor(_ workspace: String) -> Color {
    let total = workspace.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    return AtlasTheme.workspaceTints[abs(total) % AtlasTheme.workspaceTints.count]
}

struct WorkspaceRow: View {
    let icon: String
    let name: String
    let count: Int?
    var detail: String?
    var badge: Bool = false
    var a11yID: String?
    var spokenOverride: String?
    var spokenHint: String?
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button(action: action) {
            rowContent
        }
        .buttonStyle(.plain)
        .accessibilityLabel(spokenOverride ?? WorkspaceThreadJudgment.workspaceSpoken(name: name, count: count, detail: detail, badge: badge))
        .accessibilityHint(spokenHint ?? "abre \(name)")
        .accessibilityIdentifier(a11yID ?? "")
    }

    var rowContent: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .symbolRenderingMode(.hierarchical)
                .atlasSans(18).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(name).font(.system(.body)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                    .accessibilityHidden(true)
                if let detail, !detail.isEmpty {
                    Text(detail)
                        .font(.system(.caption))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .lineLimit(1)
                        .accessibilityHidden(true)
                }
            }
            Spacer(minLength: 8)
            if badge {
                Circle()
                    .fill(AtlasTheme.alert)
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true)
            }
            if let count {
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
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .contentShape(Rectangle())
    }
}

// MARK: - Masthead / a11y

extension RootView {
    func mastheadSpokenLabel(auditModeEnabled: Bool) -> String {
        auditModeEnabled ? "Atlas, modo auditoria" : "Atlas"
    }

    func mastheadSpokenHint() -> String {
        "pressione e segure para alternar modo auditoria"
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
            Text(HomeOpsJudgment.productAuditBadge)
                .font(AtlasFont.mono(8))
                .tracking(1.0)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Masthead body

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

// MARK: - Top bar

extension RootView {
    var topBarTrailing: some View {
        // Só busca: o "+" saiu — a pílula "Escreva ao Atlas" é o único ponto
        // de partida (abre o picker: sem repositório ou um repo por recência).
        CircleButton(icon: "magnifyingglass") { path.append(Route.search) }
            .keyboardShortcut("k", modifiers: .command)
            .accessibilityLabel(searchSpokenLabel())
            .accessibilityHint(HomeOpsJudgment.spokenSearchHint)
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

extension RootView {
    var topBarAvatar: some View {
        Button {
            showingProfile = true
        } label: {
            Image(systemName: "person.fill")
                .atlasSans(18)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 44, height: 44)
                .atlasGlassCircle()
        }
        .accessibilityIdentifier(A11yID.topbarProfile)
        .accessibilityLabel(WorkspaceThreadJudgment.spokenProfile)
        .accessibilityHint(WorkspaceThreadJudgment.spokenProfileHint)
        .sheet(isPresented: $showingProfile) { AtlasProfileSheet() }
    }
}

extension RootView {
    var topBarCodeButton: some View {
        // Sem ponto vermelho (ordem 2026-07-18): a exceção fala DENTRO do
        // Código, com palavra — não com pingo no chrome.
        CircleButton(icon: "point.3.connected.trianglepath.dotted") { path.append(Route.code) }
            .accessibilityLabel(RootHomeBody.spokenCodeTopBar(hub: codeHub))
            .accessibilityHint(HomeOpsJudgment.spokenCodeTopBarHint)
            .accessibilityIdentifier(A11yID.topbarCode)
    }
}


// MARK: - Route destinations

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

// MARK: - RootChromeLifecycle

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

// MARK: - RootChromeDeepLink

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

// MARK: - Conversation / code destinations

// MARK: - Conversation / code destinations

// MARK: - RootChromeConversationRoutes

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
        WorkspaceView(workspaceKey: nil, title: WorkspaceJudgment.productConversasTitle, freeOnly: true)
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
                emptyPrompt: WorkspaceAskContext.productInvite(workspaceName: name),
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
                title: WorkspaceJudgment.productNewConversationTitle,
                emptyPrompt: HomeAskContext.productInvite,
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
            emptyPrompt: ConversationOccasionPack.productInvite,
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

// MARK: - BreathingDiamond

extension BreathingDiamond {
    var breathingDiamondShape: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(AtlasTheme.accent)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(45))
            .scaleEffect(on ? 1.18 : 1)
            .opacity(on ? 0.45 : 1)
            .accessibilityHidden(true)
    }
}

extension BreathingDiamond {
    func applyBreathHandlers<Content: View>(_ content: Content) -> some View {
        content
            .onAppear {
                if effectiveReduceMotion {
                    on = false
                } else {
                    withAnimation(AtlasMotion.breath(0.9)) { on = true }
                }
            }
            .onChange(of: effectiveReduceMotion) { _, paused in
                if paused {
                    on = false
                } else if !on {
                    withAnimation(AtlasMotion.breath(0.9)) { on = true }
                }
            }
    }
}

struct BreathingDiamond: View {
    let size: CGFloat
    var reduceMotion: Bool? = nil

    @Environment(\.accessibilityReduceMotion) var envReduceMotion
    @State var on = false

    var effectiveReduceMotion: Bool { reduceMotion ?? envReduceMotion }

    var body: some View {
        applyBreathHandlers(breathingDiamondShape)
    }
}

// MARK: - Profile sheet

struct AtlasProfileSheet: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss

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
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(AtlasCloseToolbarButton.productTitle) { dismiss() }
                        .atlasSans(15, .medium)
                        .tint(AtlasTheme.textSecondary)
                }
            }
            .accessibilityIdentifier(A11yID.profileSheet)
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
            Text(HomeOpsJudgment.productOperatorSubtitle)
                .atlasSans(13)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(HomeOpsJudgment.spokenOperatorProfile)
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
                Text(HomeOpsJudgment.productAuditModeLabel).atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(HomeOpsJudgment.productAuditModeDetail)
                    .atlasSans(12).foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .tint(AtlasTheme.accent)
        .padding(.horizontal, 14).padding(.vertical, 12)
        .atlasCard()
        .accessibilityIdentifier(A11yID.profileAuditToggle)

        Text(HomeOpsJudgment.productAppVersion(appVersion))
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.top, 8)
    }

    private func profileLine(_ label: String, value: String, mono: Bool = false) -> some View {
        HStack {
            Text(label).atlasSans(15).foregroundStyle(AtlasTheme.textSecondary)
            Spacer()
            if mono {
                Text(value).font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            } else {
                Text(value).atlasSans(15)
                    .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(HomeOpsJudgment.spokenProfileLine(label: label, value: value))
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

// MARK: - AtlasTheme

// MARK: - AtlasTheme

// MARK: - AtlasTheme

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

private struct AtlasCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let fillOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(AtlasTheme.surface.opacity(fillOpacity)))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(AtlasTheme.separator, lineWidth: 1))
    }
}

extension View {
    func atlasCard(cornerRadius: CGFloat = AtlasTheme.Radius.card, fillOpacity: Double = 1) -> some View {
        modifier(AtlasCardModifier(cornerRadius: cornerRadius, fillOpacity: fillOpacity))
    }
}

extension AtlasTheme {
    static let domOperacional = Color(hex: 0x9B7A3F) // bronze
    static let domAutonomos = Color(hex: 0x6FA06A)   // verde (moss clareado p/ dark)

    enum Space {
        static let screen: CGFloat = 20
        static let row: CGFloat = 13
    }
}

extension AtlasTheme {
    static let textPrimary = Color(hex: 0xD6DDE2)
    static let textSecondary = Color(hex: 0x95A3AC)
    static let textTertiary = Color(hex: 0x677482)
    static let accent = Color(hex: 0xD4A85A)
    static let goldVeil = Color(hex: 0xD4A85A, alpha: 0.10)
    static let goldBorder = Color(hex: 0xD4A85A, alpha: 0.34)
    static let prussian = Color(hex: 0x7FA7C4)
    static let alert = Color(hex: 0xE08C8C)

    /// Só identidade de workspace. Frios e de peso parecido para nenhum deles
    /// puxar mais atenção que outro — e nenhum colide com estado ou domínio.
    static let workspaceTints = [
        prussian,                 // azul
        Color(hex: 0x6FA9A2),     // teal
        Color(hex: 0x8E97C4),     // lavanda fria
        Color(hex: 0x8AA7B8),     // aço
    ]
}

extension AtlasTheme {
    enum Radius {
        static let card: CGFloat = 14
        static let control: CGFloat = 12
        static let soft: CGFloat = 10
    }
}

extension AtlasTheme {
    static let bg = Color(hex: 0x1D2B34)
    static let bgRecessed = Color(hex: 0x15212A)
    static let surface = Color(hex: 0x243743)
    static let surfaceHi = Color(hex: 0x2D4351)
    static let separator = Color(hex: 0x313F47)
    static let separatorSoft = Color(hex: 0x27353E)
}

enum AtlasTheme {}
// MARK: - AtlasMotion

extension AtlasMotion {
    static func softImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func mediumImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func lightImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

extension AtlasMotion {
    static func successNotification(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

struct NumericTextTransition: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.contentTransition(.numericText())
        } else {
            content
        }
    }
}

@MainActor
enum AtlasMotionPresentation {
    static func editorial(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : AtlasMotion.editorial
    }
}

enum AtlasMotion {
    static let instinct: Double = 0.18
    static let considered: Double = 0.32

    static let editorial = Animation.timingCurve(0.22, 1, 0.36, 1, duration: considered)
    static let arrival = Animation.spring(response: 0.42, dampingFraction: 0.82)
    static func breath(_ duration: Double = 0.9) -> Animation {
        .easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}
// MARK: - AtlasGlassCircle

struct AtlasGlassCircle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Circle())
        } else {
            content.background(Circle().fill(AtlasTheme.surface))
        }
    }
}

struct AtlasGlassCapsule: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Capsule())
        } else {
            // Fallback pré-26: recessed quieto (mockup home), não surface chapado.
            content.background(
                Capsule().fill(AtlasTheme.bgRecessed.opacity(0.82))
                    .overlay(Capsule().stroke(AtlasTheme.separator.opacity(0.9), lineWidth: 1)))
        }
    }
}

/// Chrome único da pílula agêntica = craft Home (lei pétrea pílula §2).
/// Vidro + fio de ouro artesanal. Só o convite muda por superfície.
struct AtlasAgenticPillChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            // Hit-test friendly fill sob glass no iOS 26 (identifier não some).
            .background { Capsule().fill(AtlasTheme.bgRecessed.opacity(0.01)) }
            .atlasGlassCapsule()
            .overlay(
                Capsule()
                    .strokeBorder(Self.goldFilament, lineWidth: 0.75)
            )
    }

    /// Fio de ouro da home — não goldBorder chapado, não shadow solto.
    static var goldFilament: LinearGradient {
        LinearGradient(
            colors: [
                AtlasTheme.accent.opacity(0.22),
                AtlasTheme.accent.opacity(0.04),
                AtlasTheme.accent.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func atlasGlassCircle() -> some View { modifier(AtlasGlassCircle()) }
    /// Mesma lei para pílulas/cápsulas de chrome (composer da home, new pill).
    func atlasGlassCapsule() -> some View { modifier(AtlasGlassCapsule()) }
    /// Chrome canônico da pílula: glass + fio de ouro Home. Use em toda superfície.
    func atlasAgenticPillChrome() -> some View { modifier(AtlasAgenticPillChrome()) }
}
// MARK: - AtlasType

extension AtlasFont {
    static func anchorLarge(_ size: CGFloat) -> Font.TextStyle? {
        switch size {
        case 28...: return .largeTitle
        case 22..<28: return .title2
        case 17..<22: return .body
        default: return nil
        }
    }
}

extension AtlasFont {
    static func anchorSmall(_ size: CGFloat) -> Font.TextStyle {
        switch size {
        case 14..<17: return .callout
        case 12..<14: return .footnote
        default: return .caption2
        }
    }
}

extension AtlasFont {
    static func anchor(_ size: CGFloat) -> Font.TextStyle {
        anchorLarge(size) ?? anchorSmall(size)
    }
}

extension View {
    func atlasSans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> some View {
        modifier(AtlasSansFont(size: size, weight: weight))
    }

    /// Seleção de um controle (filtro, segmentado). Ouro é ESTADO do sistema
    /// — marca, "novo", commit — nunca "este botão está apertado".
    func atlasChipSelection(_ active: Bool) -> some View {
        foregroundStyle(active ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
            .background(
                Capsule().fill(active ? AtlasTheme.surface : AtlasTheme.bgRecessed)
                    .overlay(Capsule().stroke(
                        active ? AtlasTheme.separator : AtlasTheme.separatorSoft,
                        lineWidth: 1
                    ))
            )
    }

    /// Esmaece as pontas de uma fila horizontal. Sem isto o último chip é
    /// decepado pelo bezel e lê como bug de layout, não como "há mais".
    func atlasScrollEdgeFade() -> some View {
        mask(
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: 0.94),
                    .init(color: .clear, location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

struct AtlasSansFont: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize
    let size: CGFloat
    let weight: Font.Weight

    func body(content: Content) -> some View {
        content.font(AtlasFont.sans(size, weight: weight, at: typeSize))
    }
}

extension AtlasFont {
    @MainActor
    static func sans(_ size: CGFloat, weight: Font.Weight, at typeSize: DynamicTypeSize) -> Font {
        .system(size: size * AtlasSansScale.factor(uiTextStyle(anchor(size)), typeSize),
                weight: weight)
    }
}

extension AtlasFont {
    static func uiTextStyle(_ style: Font.TextStyle) -> UIFont.TextStyle {
        switch style {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        default: return .body
        }
    }

    static func contentCategory(_ typeSize: DynamicTypeSize) -> UIContentSizeCategory {
        switch typeSize {
        case .xSmall: return .extraSmall
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        case .xLarge: return .extraLarge
        case .xxLarge: return .extraExtraLarge
        case .xxxLarge: return .extraExtraExtraLarge
        case .accessibility1: return .accessibilityMedium
        case .accessibility2: return .accessibilityLarge
        case .accessibility3: return .accessibilityExtraLarge
        case .accessibility4: return .accessibilityExtraExtraLarge
        case .accessibility5: return .accessibilityExtraExtraExtraLarge
        @unknown default: return .large
        }
    }
}

@MainActor
enum AtlasSansScale {
    private static var table: [UIFont.TextStyle: [DynamicTypeSize: CGFloat]] = [:]

    static func prime() {
        guard table.isEmpty else { return }
        let styles: [UIFont.TextStyle] = [
            .largeTitle, .title1, .title2, .title3, .headline, .subheadline,
            .body, .callout, .footnote, .caption1, .caption2,
        ]
        for style in styles {
            let metrics = UIFontMetrics(forTextStyle: style)
            var row: [DynamicTypeSize: CGFloat] = [:]
            for typeSize in DynamicTypeSize.allCases {
                let traits = UITraitCollection(
                    preferredContentSizeCategory: AtlasFont.contentCategory(typeSize))
                row[typeSize] = metrics.scaledValue(for: 100, compatibleWith: traits) / 100
            }
            table[style] = row
        }
    }

    static func factor(_ style: UIFont.TextStyle, _ typeSize: DynamicTypeSize) -> CGFloat {
        prime()
        return table[style]?[typeSize] ?? 1
    }
}

enum AtlasFont {
    static func serif(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        let name: String
        switch weight {
        case .semibold: name = "Fraunces-SemiBold"
        default: name = "Fraunces-Regular"
        }
        return .custom(name, size: size, relativeTo: anchor(size))
    }

    static func serifItalic(_ size: CGFloat) -> Font {
        .custom("Fraunces-Italic", size: size, relativeTo: anchor(size))
    }

    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom(weight == .medium ? "JetBrainsMono-Medium" : "JetBrainsMono-Regular",
                size: size, relativeTo: anchor(size))
    }
}

// MARK: - AtlasInteraction

// MARK: - PressableScale

struct PressableScale: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.96 : 1))
            .animation(
                reduceMotion
                    ? nil
                    : (configuration.isPressed
                        ? .easeOut(duration: AtlasMotion.instinct)
                        : .spring(response: 0.25, dampingFraction: 0.6)),
                value: configuration.isPressed
            )
    }
}
// MARK: - SwipeBackEnabler

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    /// Só permite o pop quando há para onde voltar — a raiz nunca trava.
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
// MARK: - NavigationInteractivePopEnabler

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

// MARK: - Close toolbar

struct AtlasCloseToolbarButton: View {
    /// Visible chrome title (product face); a11y uses spokenLabel.
    static let productTitle = "Fechar"
    var title: String = productTitle
    let spokenLabel: String
    var spokenHint: String = ""
    var accessibilityID: String? = nil
    let reduceMotion: Bool
    let action: () -> Void

    var body: some View {
        Button(title) {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        }
        .tint(AtlasTheme.textSecondary)
        .accessibilityLabel(spokenLabel)
        .accessibilityHint(spokenHint)
        .modifier(CloseToolbarA11yID(accessibilityID))
    }
}

struct CloseToolbarA11yID: ViewModifier {
    let id: String?
    init(_ id: String?) { self.id = id }
    func body(content: Content) -> some View {
        if let id { content.accessibilityIdentifier(id) } else { content }
    }
}

// MARK: - AtlasPresentationUtils

// MARK: - LoadPhase

enum LoadPhase: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}
// MARK: - StringNonEmpty

extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
// MARK: - AtlasAreaOf

extension AtlasArea {
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
// MARK: - LiveSessionSnapshot

struct LiveSessionSnapshot: Identifiable, Equatable {
    let id: String            // traceId corrente (estável por execução)
    let threadId: ThreadID?   // para Route.thread; nil se conversa nova local
    let title: String
    let phaseTitle: String
    let timing: AtlasExecutionPresence.Timing
    let elapsedActiveMs: Int?
    let runningSince: Date?
    let pauseTimestamp: Date?
    /// 1ª observação local — só ordenação; nunca exibido como duração.
    let startedAt: Date
    let isRemote: Bool
}
// MARK: - AtlasUserMessage

func atlasUserMessage(forAPI error: Error) -> String? {
    guard let api = error as? AtlasApiError else { return nil }
    switch api.status {
    case 401, 403: return "A sessão do Atlas precisa ser reconectada."
    case 408, 429: return "O Atlas está ocupado. Este turno continua recuperável."
    case 500...599: return "O servidor Atlas está temporariamente indisponível."
    default: return api.message
    }
}

func atlasUserMessage(forStream error: Error) -> String? {
    guard error is AtlasInteractionStreamError else { return nil }
    return "A conexão com a execução caiu. O Atlas retomará este turno automaticamente."
}

func atlasUserMessage(forURL error: Error) -> String? {
    guard let urlError = error as? URLError else { return nil }
    switch urlError.code {
    case .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost,
         .cannotFindHost, .timedOut:
        return "A conexão caiu. O Atlas vai recuperar este turno quando a rede voltar."
    default:
        return "Não foi possível falar com o Atlas agora. Tente novamente."
    }
}

func atlasUserMessage(for error: Error) -> String {
    if let message = atlasUserMessage(forStream: error) { return message }
    if let message = atlasUserMessage(forURL: error) { return message }
    if let message = atlasUserMessage(forAPI: error) { return message }
    return "A execução foi interrompida. Tente novamente."
}
// MARK: - AtlasWorkspace

struct Workspace: Identifiable, Hashable {
    let id: String     // chave = nome de pasta minúsculo
    let name: String   // exibição
    let count: Int
}

enum AtlasArea: String, CaseIterable, Identifiable {
    case tudo, operacional, autonomos, programacao
    var id: String { rawValue }
}

extension AtlasArea {
    var label: String {
        labelDomain ?? "Tudo"
    }
}

extension AtlasArea {
    var labelDomain: String? {
        switch self {
        case .operacional: return "Operacional"
        case .autonomos: return "Autônomos"
        case .programacao: return "Programação"
        default: return nil
        }
    }
}
// MARK: - AtlasConventionalCommit

enum AtlasConventionalCommit {
    // ponytail: whitelist de tipos — evita falso-positivo de mensagem comum
    // com ":" ("nota: isso"). Cobre os tipos usados no Atlas + os padrão.
    private static let knownTypes: Set<String> = [
        "feat", "fix", "docs", "polish", "refactor", "chore",
        "test", "style", "perf", "build", "ci", "revert", "wip"
    ]

    /// `type` normalizado: minúsculo, PRIMEIRO segmento com escopo
    /// ("fix(ui)+polish(ui)" → "fix(ui)"); nil quando não-convencional.
    static func split(_ message: String) -> (type: String?, subject: String) {
        guard let sep = message.range(of: ": ") else { return (nil, message) }
        let head = String(message[..<sep.lowerBound])
        let subject = String(message[sep.upperBound...]).trimmingCharacters(in: .whitespaces)
        guard !subject.isEmpty, let type = conventionalType(head) else { return (nil, message) }
        return (type, subject)
    }

    private static func conventionalType(_ head: String) -> String? {
        guard !head.isEmpty, head.count <= 40, !head.contains(" ") else { return nil }
        // Primeiro segmento (antes de '+'): o tipo primário do commit.
        let segment = head.split(separator: "+", maxSplits: 1).first.map(String.init) ?? head
        let typeWord = segment.prefix { $0.isLetter }
        let remainder = segment[typeWord.endIndex...]
        // O resto do segmento tem de ser escopo/marca VÁLIDA ("(...)", "!" ou
        // vazio) — senão "fix-me"/"ci-cd" viraria tipo (falso-positivo).
        guard knownTypes.contains(typeWord.lowercased()), isValidScope(remainder) else { return nil }
        return typeWord.lowercased() + remainder
    }

    private static func isValidScope(_ raw: Substring) -> Bool {
        var s = raw
        if s.hasSuffix("!") { s = s.dropLast() }
        if s.isEmpty { return true }
        return s.first == "(" && s.last == ")"
    }
}
