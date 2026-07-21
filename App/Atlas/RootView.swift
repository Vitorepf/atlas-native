import SwiftUI
import AtlasCore
import PhotosUI

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

// MARK: - AgenticPill

// MARK: - AgenticPill

struct AgenticPillFace<Trailing: View>: View {
    let invite: String
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 12) {
            RootView.HomeComposerStar()
            Text(invite)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            trailing()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .atlasAgenticPillChrome()
    }
}

extension AgenticPillFace where Trailing == EmptyView {
    init(invite: String) {
        self.invite = invite
        self.trailing = { EmptyView() }
    }
}

/// Chrome único da pílula agêntica (baseline Home craft).
/// Só mudam: `invite`, `action`, a11y, trailing opcional (Code clear).
/// Pack nunca na cara — só viaja em `turnFacts`.
struct AgenticPill<Trailing: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let invite: String
    var accessibilityId: String = A11yID.arenaPremiumAskPill
    var accessibilityHintText: String = "Abre conversa com o contexto desta tela"
    @ViewBuilder var trailing: () -> Trailing
    let action: () -> Void

    var body: some View {
        Button(action: {
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            action()
        }) {
            AgenticPillFace(invite: invite, trailing: trailing)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(invite)
        .accessibilityHint(accessibilityHintText)
        .accessibilityIdentifier(accessibilityId)
    }
}

extension AgenticPill where Trailing == EmptyView {
    init(
        invite: String,
        accessibilityId: String = A11yID.arenaPremiumAskPill,
        accessibilityHintText: String = "Abre conversa com o contexto desta tela",
        action: @escaping () -> Void
    ) {
        self.invite = invite
        self.accessibilityId = accessibilityId
        self.accessibilityHintText = accessibilityHintText
        self.trailing = { EmptyView() }
        self.action = action
    }
}

/// Compat: call sites antigos Arena/Autônomos.
typealias ArenaPremiumAskPill = AgenticPill
// MARK: - AgenticAskDock

struct AgenticAskDock<Pill: View>: View {
    @ViewBuilder var pill: () -> Pill

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg.opacity(0.92), AtlasTheme.bg],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            .allowsHitTesting(false)
            pill()
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.bottom, 10)
        }
        .background(AtlasTheme.bg.opacity(0.01))
    }
}

extension View {
    /// Sheet presentation canônica do ask agêntico (WAVE-005).
    func agenticAskSheetPresentation() -> some View {
        self
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(AtlasTheme.bg)
            .presentationCornerRadius(28)
    }
}
// MARK: - AgenticOccasionPack

struct AgenticOccasionPack: Equatable {
    enum CanDo: String, Equatable {
        /// Chat NL de leitura/julgamento; sem tool write.
        case readChat = "read_chat"
        /// Só status/headline; sem chat útil além de perguntar.
        case statusOnly = "status_only"
        /// Run/stop/pause só via CTA da face — NL não autoriza write.
        case ctaOnlyRunStop = "cta_only_run_stop"
        /// Controles locais da face (pause/retomar) + chat de leitura.
        case faceCTALocal = "face_cta_local_plus_read_chat"
    }

    var surface: String
    var subject: String
    var anchors: [String] = []
    var facts: [String] = []
    var absences: [String] = []
    var canDo: CanDo
    /// Bloco opcional (ex.: server ask facts) anexado após a gramática.
    var appendix: String? = nil

    /// Render key:value estável — mesma forma em todas as faces ops.
    func render() -> String {
        var lines: [String] = [
            "surface: \(surface)",
            "subject: \(subject)",
        ]
        if anchors.isEmpty {
            lines.append("anchors: []")
        } else {
            lines.append("anchors:")
            for a in anchors {
                lines.append("- \(a)")
            }
        }
        if facts.isEmpty {
            lines.append("facts: []")
        } else {
            lines.append("facts:")
            for f in facts {
                lines.append("- \(f)")
            }
        }
        if absences.isEmpty {
            lines.append("absences: []")
        } else {
            lines.append("absences:")
            for a in absences {
                lines.append("- \(a)")
            }
        }
        lines.append("can_do: \(canDo.rawValue)")
        if let appendix = appendix?.trimmingCharacters(in: .whitespacesAndNewlines), !appendix.isEmpty {
            lines.append("---")
            lines.append("appendix:")
            lines.append(appendix)
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - ConversationView

// MARK: - Host

struct ConversationView: View {
    let title: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) var session
    @State var model: ConversationModel
    @State var mode = "geral"
    @State var showModeSheet = false
    @State var showWorkspaceSheet = false
    @State var showEffortSheet = false
    @State var showQueueSheet = false
    @State var showOutline = false
    @State var reviewTrace: ConversationReviewTraceRef?
    @State var artifactTrace: ConversationReviewTraceRef?
    @State var steerTrace: ConversationSteerTraceRef?
    @State var showAttachmentSheet = false
    @State var pickedPhoto: PhotosPickerItem?
    @State var showFileImporter = false
    @State var showCamera = false
    @FocusState var focused: Bool
    @State var awayFromBottom = false
    @State var readSealConfirming = false
    @State var lastCacheCapturedAt: Date?
    @State var lastScrollAt: CFAbsoluteTime = 0
    @State var lastScrollBubbleCount = 0

    let startFocused: Bool
    let emptyPrompt: String?
    let emptySuggestions: [String]?
    /// Home partida only — unlocks default empty catalog via Judgment (WAVE-084).
    let isHomePartida: Bool
    let onThread: ((ThreadID) -> Void)?
    /// Sheet do grafo: sem chevron — o gesto de arrastar fecha.
    let hidesNavigationBack: Bool

    var body: some View {
        conversationLifecycleModifiers(conversationPage)
    }

    init(
        client: AtlasClient,
        threadId: ThreadID?,
        title: String,
        emptyPrompt: String? = nil,
        emptySuggestions: [String]? = nil,
        isHomePartida: Bool = false,
        taskKind: String? = nil,
        workspace: String? = nil,
        draft: String = "",
        turnFacts: ((String) async -> String?)? = nil,
        onThread: ((ThreadID) -> Void)? = nil,
        hidesNavigationBack: Bool = false
    ) {
        self.title = title
        self.startFocused = threadId == nil
        self.emptyPrompt = emptyPrompt
        self.emptySuggestions = emptySuggestions
        self.isHomePartida = isHomePartida
        self.onThread = onThread
        self.hidesNavigationBack = hidesNavigationBack
        _model = Self.initModelState(
            client: client,
            threadId: threadId,
            taskKind: taskKind,
            workspace: workspace,
            draft: draft,
            turnFacts: turnFacts
        )
    }

}

extension ConversationView {
    func spokenConversationEmptyPrefix() -> String? {
        if model.loadError != nil, model.bubbles.isEmpty {
            return "\(title), falha ao carregar"
        }
        if model.bubbles.isEmpty {
            let organ = ConversationEmptyJudgment.spokenEmptyOrgan(
                prompt: emptyPrompt,
                suggestions: emptySuggestions,
                isHomePartida: isHomePartida,
                hasWorkspaces: !session.workspaces.isEmpty
            )
            return "\(title), \(organ)"
        }
        return nil
    }
}

// MARK: - A11y

extension ConversationView {
    func spokenConversationScreenLabel() -> String {
        if let empty = spokenConversationEmptyPrefix() { return empty }
        var parts = [title, "\(model.bubbles.count) turno\(model.bubbles.count == 1 ? "" : "s")"]
        if model.isSending { parts.append("enviando") }
        if model.showingStaleCache { parts.append("cache desatualizado") }
        return parts.joined(separator: ", ")
    }
}

extension ConversationView {
    func setToast(_ message: String) {
        if reduceMotion { model.toast = message }
        else { withAnimation(AtlasMotion.editorial) { model.toast = message } }
        UIAccessibility.post(notification: .announcement, argument: ConversationMessagesJudgment.spokenToast(message))
    }

    func clearToast() {
        if reduceMotion { model.toast = nil }
        else { withAnimation(AtlasMotion.editorial) { model.toast = nil } }
    }
}

extension ConversationView {
    @ViewBuilder
    var conversationPage: some View {
        conversationPageChrome(
            ZStack(alignment: .bottom) {
                AtlasTheme.bg.ignoresSafeArea()
                conversationMessagesStack
                conversationComposerBind
            }
        )
    }
}

extension ConversationView {
    func conversationPageChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .scrollDismissesKeyboard(.interactively)
            .accessibilityIdentifier(A11yID.conversationScreen)
            .accessibilityLabel(spokenConversationScreenLabel())
            .accessibilityHint(
                hidesNavigationBack
                    ? "arraste para baixo para fechar"
                    : ConversationMessagesJudgment.spokenScreenHint
            )
            .overlay(alignment: .top) { toast }
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.toast)
    }
}

extension ConversationView {
    var conversationComposerBind: some View {
        conversationComposerCard
    }
}

extension ConversationView {
    var conversationComposerSheetTraceAggregate: (
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        showFileImporter: Binding<Bool>,
        showCamera: Binding<Bool>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>
    ) {
        let sheets = conversationComposerSheetFlagBindings
        let traces = conversationComposerTraceBindings
        return (
            mode: sheets.mode,
            showModeSheet: sheets.showModeSheet,
            showWorkspaceSheet: sheets.showWorkspaceSheet,
            showEffortSheet: sheets.showEffortSheet,
            showQueueSheet: sheets.showQueueSheet,
            showAttachmentSheet: sheets.showAttachmentSheet,
            pickedPhoto: sheets.pickedPhoto,
            showFileImporter: sheets.showFileImporter,
            showCamera: sheets.showCamera,
            reviewTrace: traces.reviewTrace,
            artifactTrace: traces.artifactTrace,
            steerTrace: traces.steerTrace
        )
    }
}
