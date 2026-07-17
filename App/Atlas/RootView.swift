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

                    content
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
            if url.scheme == "atlas", url.host == "code",
               let repo = url.pathComponents.dropFirst().first, !repo.isEmpty {
                path.append(Route.codeGraph(repo: repo))
                return
            }
            guard url.scheme == "atlas", url.host == "execution",
                  let traceId = url.pathComponents.dropFirst().first, !traceId.isEmpty else { return }
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
            // não repete a área. O ponto vermelho preserva a exceção: sem
            // ele, uma violação real ficaria invisível no repouso.
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

    // MARK: - Content (workspaces)

    @ViewBuilder
    private var content: some View {
        switch session.phase {
        case .idle where session.threads.isEmpty, .loading where session.threads.isEmpty:
            centered {
                VStack(spacing: 18) {
                    BreathingGlyph(reduceMotion: reduceMotion)
                    Text("abrindo o Atlas…")
                        .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("abrindo o Atlas")
            }

        case .failed where session.threads.isEmpty:
            centered {
                // Falha editorial: diz O QUE houve e O QUE fazer — nunca um beco
                // sem saída. Voz do Atlas, não voz de sistema.
                VStack(spacing: 0) {
                    Text("✦")
                        .font(AtlasFont.serif(28)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
                    Spacer().frame(height: 28)
                    Text(failureHeadline)
                        .font(AtlasFont.serif(22, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    Spacer().frame(height: 12)
                    Text(session.hasToken ? "\(session.host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                        .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
                    Spacer().frame(height: 16)
                    Text(failureHint)
                        .font(.system(.subheadline)).lineSpacing(5)
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .multilineTextAlignment(.center)
                    if session.hasToken {
                        Spacer().frame(height: 28)
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            Task { await session.loadThreads() }
                        } label: {
                            Text("Tentar de novo")
                                .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.accent)
                                .padding(.horizontal, 22).padding(.vertical, 10)
                                .background(Capsule().fill(AtlasTheme.goldVeil)
                                    .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                        }
                        .buttonStyle(PressableScale())
                        .accessibilityHint("reconecta ao servidor Atlas")
                    }
                }
                .padding(.horizontal, 44)
            }

        default:   // .loaded, ou refresh/erro com conteúdo já em tela
            ScrollView {
                LazyVStack(spacing: 0) {
                    // M13: cockpit aparece para sessões locais ou vindas de outra superfície.
                    if !TurnPresence.shared.liveSessions.isEmpty || !session.remoteLiveSessions.isEmpty {
                        LiveNowSection(
                            localSessions: TurnPresence.shared.liveSessions,
                            remoteSessions: session.remoteLiveSessions,
                            onOpen: { id, title in path.append(Route.thread(id: id, title: title)) }
                        )
                    }
                    // A conversa é o centro — projeto é opcional. Aqui vivem as
                    // conversas SEM projeto: perguntas, pesquisas, pensamento
                    // livre (o uso GPT-no-iPhone). A pílula embaixo cria uma.
                    sectionLabel("CONVERSAS")
                    homeWorkspaceChips
                    WorkspaceRow(icon: "bubble.left.and.bubble.right", name: homeConversationLabel,
                                 count: homeConversationCount,
                                 detail: session.auditModeEnabled ? auditDetail : nil) {
                        path.append(homeConversationRoute)
                    }
                    rowDivider
                    sectionLabel("OPERAÇÃO")
                    WorkspaceRow(icon: "bolt.horizontal.circle", name: "Autônomos", count: nil) {
                        path.append(Route.autonomos)
                    }
                    rowDivider
                    WorkspaceRow(
                        icon: "chart.line.uptrend.xyaxis",
                        name: "Arena",
                        count: nil,
                        detail: session.arena.regressionException,
                        badge: session.arena.regressionException != nil
                    ) {
                        path.append(Route.arena)
                    }
                    .accessibilityIdentifier(A11yID.arenaHomeEntry)
                    rowDivider
                    sectionLabel("WORKSPACES")

                    WorkspaceRow(icon: "tray.full", name: "Todas as conversas", count: session.threads.count) {
                        path.append(Route.workspace(key: nil, title: "Todas"))
                    }
                    ForEach(session.workspaces) { ws in
                        rowDivider
                        WorkspaceRow(icon: "folder", name: ws.name, count: ws.count) {
                            path.append(Route.workspace(key: ws.id, title: ws.name))
                        }
                    }
                }
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .refreshable { await session.loadThreads() }
        }
    }

    // Copy por TIPO de falha (failureKind — contrato entregue pelo Codex, §5).
    // Cada falha diz o que houve e o que fazer, na voz do Atlas.
    private var failureHeadline: String {
        guard session.hasToken else { return "Falta a chave do Atlas." }
        switch session.failureKind {
        case .offline: return "Você está sem internet."
        case .timedOut: return "O Mac não respondeu a tempo."
        case .connectionRefused: return "O servidor do Atlas não está de pé."
        case .connectionLost: return "A conexão caiu no meio do caminho."
        case .unauthorized: return "A chave do Atlas foi recusada."
        case .maintenance: return "Atlas está em manutenção."
        case .serverUnavailable: return "O servidor está indisponível."
        case .other, nil: return "O servidor está fora de alcance."
        }
    }

    private var failureHint: String {
        guard session.hasToken else { return "Configure o token no Mac e reinstale — nada foi perdido." }
        switch session.failureKind {
        case .offline: return "Sem rede no iPhone. O Atlas volta sozinho assim que a conexão voltar."
        case .timedOut: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        case .connectionRefused: return "No Mac, suba o servidor: o container atlas-backend parou."
        case .connectionLost: return "Instabilidade momentânea — tentar de novo costuma resolver."
        case .unauthorized: return "O ATLAS_TOKEN mudou no servidor. Atualize o Secrets.xcconfig e reinstale."
        case .maintenance: return "O servidor pediu uma pausa via Retry-After. O app aguarda você tentar de novo quando a janela terminar."
        case .serverUnavailable: return "O servidor respondeu, mas está fora do ar. Veja os logs no Mac."
        case .other, nil: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
    }

    /// Conversas sem projeto (workspace nulo) — o modo "só conversar".
    private var freeThreadCount: Int {
        session.threads.filter { $0.workspace == nil }.count
    }

    private var homeConversationRoute: Route {
        switch homeWorkspaceFilter {
        case .some("__all"):
            return .workspace(key: nil, title: "Todas")
        case .some(let key):
            let title = session.workspaces.first(where: { $0.id == key })?.name ?? "Workspace"
            return .workspace(key: key, title: title)
        case .none:
            return .conversas
        }
    }

    private var homeConversationLabel: String {
        switch homeWorkspaceFilter {
        case .some("__all"): return "Todas as conversas"
        case .some(let key): return session.workspaces.first(where: { $0.id == key })?.name ?? "Workspace"
        case .none: return "Conversas livres"
        }
    }

    private var homeConversationCount: Int {
        switch homeWorkspaceFilter {
        case .some("__all"): return session.threads.count
        case .some(let key): return session.threads(inWorkspace: key).count
        case .none: return freeThreadCount
        }
    }

    private var auditDetail: String {
        let key = homeWorkspaceFilter ?? "livres"
        return "auditoria · filtro \(key) · \(homeConversationCount) threads"
    }

    private var homeWorkspaceChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                homeFilterChip("Livres", key: nil)
                homeFilterChip("Todas", key: "__all")
                ForEach(session.workspaces) { workspace in
                    homeFilterChip(workspace.name, key: workspace.id)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 10)
        }
        .accessibilityLabel("filtros de workspace das conversas")
        .accessibilityIdentifier(A11yID.homeWorkspaceChips)
    }

    private func homeFilterChip(_ label: String, key: String?) -> some View {
        let active = homeWorkspaceFilter == key
        return Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            homeWorkspaceFilter = key
        } label: {
            Text(label)
                .font(.system(.caption, weight: .medium))
                .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface))
                .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("filtrar conversas por \(label)")
        .accessibilityIdentifier(A11yID.homeWorkspaceChip(key ?? "__free"))
    }

    private func sectionLabel(_ t: String) -> some View {
        Text(t)
            .font(.system(.caption, weight: .semibold))
            .tracking(1.4)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 6)
            .padding(.bottom, 12)
    }

    private var rowDivider: some View {
        Divider().overlay(AtlasTheme.separator).padding(.leading, AtlasTheme.Space.screen + 36)
    }

    private func centered<V: View>(@ViewBuilder _ v: () -> V) -> some View {
        VStack { Spacer(); v(); Spacer() }.frame(maxWidth: .infinity, maxHeight: .infinity)
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

// MARK: - Componentes compartilhados

/// O ✦ respirando — a marca viva do Atlas nos estados de espera.
struct BreathingGlyph: View {
    let reduceMotion: Bool
    @State private var on = false
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
    /// Ponto de exceção: só aparece quando existe algo que fala. Silêncio é o
    /// estado normal — o botão não carrega contador decorativo.
    var badge: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium)).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 44, height: 44).background(Circle().fill(AtlasTheme.surface))
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

private struct WorkspaceRow: View {
    let icon: String
    let name: String
    let count: Int?
    var detail: String?
    var badge: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.system(size: 18)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                VStack(alignment: .leading, spacing: 3) {
                    Text(name).font(.system(.body)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                    if let detail, !detail.isEmpty {
                        Text(detail)
                            .font(.system(.caption))
                            .foregroundStyle(AtlasTheme.alert)
                            .lineLimit(1)
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
                        .font(.system(.callout))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// Linha de conversa — compartilhada com a WorkspaceView. O hub é VIVO: a
// conversa com turno executando troca o ícone pelo losango respirando e o
// contador por "executando" — você sabe onde o Atlas trabalha sem entrar.
struct ThreadRow: View {
    let thread: AtlasAiThread
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isRunning: Bool { TurnPresence.shared.runningTitles.contains(thread.title) }
    private var isNew: Bool { ConversationModel.hasNewerContent(thread) }
    private var workspaceTint: Color? { thread.workspace.map(threadWorkspaceColor) }

    var body: some View {
        HStack(spacing: 14) {
            if isRunning {
                BreathingDiamond(size: 9, reduceMotion: reduceMotion).frame(width: 22)
            } else {
                Image(systemName: "bubble.left").font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
            }
            Text(thread.title).font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1).truncationMode(.tail)
            Spacer(minLength: 8)
            if isNew && !isRunning {
                Text("novo")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(AtlasTheme.goldVeil))
                    .accessibilityLabel("novo desde a última visita")
            }
            if isRunning {
                Text("executando").font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent)
            } else {
                Text("\(thread.messageCount)")
                    .font(.system(size: 16))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .overlay(alignment: .leading) {
            if let workspaceTint {
                Rectangle()
                    .fill(workspaceTint.opacity(0.85))
                    .frame(width: 2)
                    .padding(.vertical, 10)
            }
        }
        .contentShape(Rectangle())
        .accessibilityHint(isRunning ? "Atlas executando nesta conversa" : "")
    }
}

private func threadWorkspaceColor(_ workspace: String) -> Color {
    let palette = [AtlasTheme.accent, AtlasTheme.prussian, AtlasTheme.domAutonomos, AtlasTheme.domOperacional]
    let total = workspace.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    return palette[abs(total) % palette.count]
}
