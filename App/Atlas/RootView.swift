import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: RootView + RootRoute fused

// MARK: - Route types

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

// MARK: - Root host

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

// MARK: - Home chrome

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
    func handleExecutionHomeDeepLink() {
        // WAVE-064: Seguir = LiveNow attention head (not chrono last).
        // Never invent thread; empty head → stay home.
        path = NavigationPath()
        if let snap = LiveNowJudgment.headForOpen(
            local: TurnPresence.shared.liveSessions,
            remote: session.remoteLiveSessions
        ), let threadId = snap.threadId {
            path.append(Route.thread(id: threadId, title: snap.title))
        }
    }
}

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
                rootHomeBodyStack
                inputBar
            }
        )
    }
}

extension RootView {
    @ViewBuilder
    var rootHomeBodyStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 4)
                .padding(.bottom, 14)

            RootHomeBody(
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
        Button { showingNewPicker = true } label: {
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
    // WAVE-016: face canônica (mesmo órgão que Arena/Autônomos/Workspace).
    var inputBarContent: some View {
        AgenticPillFace(invite: HomeAskContext.invite)
    }
}
