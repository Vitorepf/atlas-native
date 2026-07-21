import SwiftUI
import AtlasCore

// WAVE-015 fused

// --- RootView+Chrome+A11yHome+InputPill.swift ---
extension RootView {
    func inputPillSpokenLabel() -> String {
        "Escreva ao Atlas, nova conversa"
    }

    func inputPillSpokenHint() -> String {
        "abre a escolha: sem repositório ou um repositório recente"
    }
}

// --- RootView+Chrome+A11yHome+SearchNew.swift ---
extension RootView {
    func searchSpokenLabel() -> String {
        "buscar conversas"
    }
}

// --- RootView+DeepLinksExecutionHome.swift ---
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

// --- RootView+HomeAtmosphere.swift ---
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

// --- RootView+HomeChrome.swift ---
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

// --- RootView+HomeStack.swift ---
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

// --- RootView+HomeStackSections.swift ---
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

// --- RootView+InputBar.swift ---
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

// --- RootView+InputBarBackground.swift ---
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

// --- RootView+InputBarContent+Star.swift ---
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

// --- RootView+InputBarContent.swift ---
extension RootView {
    // A pílula agêntica: ✦ vivo + chrome canônico Home (atlasAgenticPillChrome).
    var inputBarContent: some View {
        HStack(spacing: 12) {
            HomeComposerStar()
            Text(HomeAskContext.invite)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .atlasAgenticPillChrome()
    }
}

