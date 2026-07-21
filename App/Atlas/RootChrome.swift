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

func threadWorkspaceColor(_ workspace: String) -> Color {
    let palette = [AtlasTheme.accent, AtlasTheme.prussian, AtlasTheme.domAutonomos, AtlasTheme.domOperacional]
    let total = workspace.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    return palette[abs(total) % palette.count]
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
            Text("AUDITORIA")
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
        .accessibilityLabel(WorkspaceThreadJudgment.profileLabel)
        .accessibilityHint(WorkspaceThreadJudgment.profileHint)
        .sheet(isPresented: $showingProfile) { AtlasProfileSheet() }
    }
}

extension RootView {
    var topBarCodeButton: some View {
        // Sem ponto vermelho (ordem 2026-07-18): a exceção fala DENTRO do
        // Código, com palavra — não com pingo no chrome.
        CircleButton(icon: "point.3.connected.trianglepath.dotted") { path.append(Route.code) }
            .accessibilityLabel(RootHomeBody.codeTopBarLabel(hub: codeHub))
            .accessibilityHint("abre radar de repositórios")
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
