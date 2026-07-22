import SwiftUI
import AtlasCore
import Charts

// GOD-RESTRUCTURE: ArenaPremiumShell + AtlasArenaView entry fused

// MARK: - Shell

struct ArenaPremiumShell: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AtlasSession.self) private var session
    @Bindable var model: ArenaModel
    @Binding var selectedTab: ArenaPremiumTab
    @Binding var destination: ArenaPremiumDestination?
    @Binding var selectedSuite: AtlasArenaSuite?
    @Binding var selectedCapability: AtlasArenaCapability?
    @Binding var showingRunSheet: Bool
    @Binding var stoppingRun: AtlasArenaLiveRun?
    @State private var showingAsk = false
    @State private var askThreadId: ThreadID?
    @State private var askDraft = ""
    /// Sheet local da suíte — evita race do binding com o contentor AtlasArenaView.
    @State private var suiteSheet: AtlasArenaSuite?

    var body: some View {
        VStack(spacing: 0) {
            ArenaPremiumTabBar(selection: $selectedTab)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 6)
                .padding(.bottom, 8)
                .background(AtlasTheme.bg)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 26) {
                    selectedContent
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 8)))
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 12)
                .padding(.bottom, 108)
            }
            .scrollIndicators(.hidden)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if destination == nil {
                askPillDock
            }
        }
        .toolbar { addToolbarItem }
        .navigationDestination(item: $destination) { target in
            ArenaPremiumDestinationView(
                target: target,
                model: model,
                onStop: { stoppingRun = $0 },
                onSuite: { openSuite($0) }
            )
        }
        .sheet(item: $selectedCapability) { capability in
            ArenaPremiumCapabilityDetail(
                capability: capability,
                scoreboard: model.scoreboard,
                engineId: model.arenaSelectedEngineID
            )
        }
        .sheet(item: $stoppingRun) { run in
            ArenaPremiumStopSheet(model: model, run: run)
        }
        .fullScreenCover(item: $suiteSheet) { suite in
            ArenaSuiteSheet(suite: suite)
        }
        .sheet(isPresented: $showingAsk) {
            askConversationSheet
        }
    }

    private func openSuite(_ suite: AtlasArenaSuite) {
        selectedSuite = suite
        suiteSheet = suite
    }

    private var askPillDock: some View {
        AgenticAskDock {
            AgenticPill(
                invite: ArenaPremiumAskContext.productInvite(tab: selectedTab, destination: destination),
                accessibilityId: A11yID.arenaPremiumAskPill
            ) {
                askDraft = ""
                showingAsk = true
            }
        }
    }

    private var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: "Arena",
            emptyPrompt: ArenaPremiumAskContext.productInvite(tab: selectedTab, destination: destination),
            emptySuggestions: ArenaPremiumAskContext.emptySuggestions(
                tab: selectedTab,
                destination: destination
            ),
            taskKind: "arena",
            workspace: nil,
            draft: askDraft,
            turnFacts: { [model, selectedTab, destination] _ in
                ArenaPremiumAskContext.facts(
                    model: model,
                    tab: selectedTab,
                    destination: destination
                )
            },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .agenticAskSheetPresentation()
    }

    @ViewBuilder
    private var selectedContent: some View {
        if model.composite == nil, case .failed = model.phase {
            ArenaPremiumLoadFailureView(model: model)
        } else {
            switch selectedTab {
            case .now:
                ArenaPremiumNowView(
                    model: model,
                    onRun: { showingRunSheet = true },
                    onNavigate: { destination = $0 },
                    onStop: { stoppingRun = $0 }
                )
            case .fleet:
                ArenaPremiumFleetView(model: model)
            case .results:
                ArenaPremiumResultsView(
                    model: model,
                    reduceMotion: reduceMotion,
                    onSuite: { openSuite($0) }
                )
            case .capabilities:
                ArenaPremiumCapabilitiesView(
                    model: model,
                    onCapability: { selectedCapability = $0 }
                )
            }
        }
    }

    @ToolbarContentBuilder
    private var addToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { showingRunSheet = true } label: {
                Image(systemName: ArenaPremiumIconography.add)
                    .atlasSans(17, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
            }
            .accessibilityLabel(ArenaStartJudgment.productNewMeasurement)
            .accessibilityHint(ArenaRunSheetJudgment.spokenStartHint)
            .accessibilityIdentifier(A11yID.arenaPremiumAdd)
        }
    }
}

// MARK: - Entry AtlasArenaView

extension AtlasArenaView {
    func arenaLifecycleA11y<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle(ArenaNowJudgment.productScreenTitle)
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension AtlasArenaView {
    func arenaLifecycleTasks<Content: View>(_ content: Content) -> some View {
        content
            .task {
                if case .idle = model.phase {
                    await model.load()
                }
            }
            .onAppear { model.setVisible(true) }
            .onDisappear { model.setVisible(false) }
            .refreshable { await model.load() }
    }
}

extension AtlasArenaView {
    func arenaLifecycleChrome<Content: View>(_ content: Content) -> some View {
        arenaLifecycleTasks(arenaLifecycleA11y(content))
    }
}

extension AtlasArenaView {
    func arenaSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showingRunSheet) {
                ArenaRunSheet(model: model)
            }
    }
}

struct AtlasArenaView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) var session
    @Bindable var model: ArenaModel
    @State var selectedSuite: AtlasArenaSuite?
    @State var showingRunSheet = false
    @State var selectedTab: ArenaPremiumTab = .now
    @State var premiumDestination: ArenaPremiumDestination?
    @State var selectedCapability: AtlasArenaCapability?
    @State var stoppingRun: AtlasArenaLiveRun?

    var body: some View {
        arenaSheets(on:
            arenaLifecycleChrome(
                ArenaPremiumShell(
                    model: model,
                    selectedTab: $selectedTab,
                    destination: $premiumDestination,
                    selectedSuite: $selectedSuite,
                    selectedCapability: $selectedCapability,
                    showingRunSheet: $showingRunSheet,
                    stoppingRun: $stoppingRun
                )
            )
        )
    }
}

// MARK: - ArenaPremiumNowView

// MARK: - View host

struct ArenaPremiumNowView: View {
    @Bindable var model: ArenaModel
    let onRun: () -> Void
    let onNavigate: (ArenaPremiumDestination) -> Void
    let onStop: (AtlasArenaLiveRun) -> Void

    var body: some View {
        Group {
            if model.composite == nil, isPreparing {
                loading
            } else {
                nowState
            }
        }
    }

    private var isPreparing: Bool {
        switch model.phase {
        case .idle, .loading: true
        case .loaded, .failed: false
        }
    }

    @ViewBuilder
    private var nowState: some View {
        switch model.livePresentation?.phase ?? .idle {
        case .running:
            ArenaPremiumRunningView(
                model: model,
                onNavigate: onNavigate,
                onStop: onStop
            )
        case .stopping:
            ArenaPremiumTerminalView(
                model: model,
                kind: .stopping,
                onRun: onRun,
                onNavigate: onNavigate
            )
        case .queued:
            ArenaPremiumQueuedView(model: model, onNavigate: onNavigate)
        case .completed:
            ArenaPremiumTerminalView(
                model: model,
                kind: .completed,
                onRun: onRun,
                onNavigate: onNavigate
            )
        case .failed:
            ArenaPremiumTerminalView(
                model: model,
                kind: .failed,
                onRun: onRun,
                onNavigate: onNavigate
            )
        case .stopped:
            ArenaPremiumTerminalView(
                model: model,
                kind: .stopped,
                onRun: onRun,
                onNavigate: onNavigate
            )
        case .idle:
            ArenaPremiumIdleView(model: model, onRun: onRun, onNavigate: onNavigate)
        }
    }

    private var loading: some View {
        VStack(alignment: .leading, spacing: 22) {
            ArenaPremiumKicker(text: ArenaNowJudgment.productPreparingKicker(), tone: .active, showsDot: true)
            Text(ArenaNowJudgment.productPreparingTitle())
                .font(AtlasFont.serif(32))
                .foregroundStyle(AtlasTheme.textPrimary)
            ProgressView()
                .tint(AtlasTheme.accent)
            Text(ArenaNowJudgment.productIndependentContracts)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 24)
        .accessibilityValue(ArenaNowFace.preparing.productWord)
    }
}

// MARK: - Phase body views

// MARK: - Host

struct ArenaPremiumIdleView: View {
    @Bindable var model: ArenaModel
    let onRun: () -> Void
    let onNavigate: (ArenaPremiumDestination) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumEmptyGlyph(symbol: "scope")
                .accessibilityIdentifier(A11yID.arenaPremiumState("idle"))
            ArenaPremiumKicker(text: ArenaNowJudgment.productIdleKicker())
            Text(ArenaNowJudgment.productIdleTitle())
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(ArenaNowJudgment.productIdleBody())
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityValue(ArenaNowFace.idle.productWord)
            ArenaPremiumAction(title: "Rodar medição", symbol: "play.fill", action: onRun)
            if model.arenaPrimaryEngine != nil {
                ArenaPremiumHairline()
                ArenaPremiumKicker(text: "Último resultado")
                ArenaPremiumDisclosureRow(
                    title: ArenaDisplay.engine(model.arenaPrimaryEngine?.engine ?? "motor"),
                    detail: model.arenaCoverageText,
                    symbol: "chart.line.uptrend.xyaxis",
                    tone: .neutral
                ) { onNavigate(.results) }
            }
        }
    }
}

struct ArenaPremiumQueuedView: View {
    @Bindable var model: ArenaModel
    let onNavigate: (ArenaPremiumDestination) -> Void

    private var queuedRuns: [AtlasArenaLiveRun] {
        model.livePresentation?.queuedRuns ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(text: ArenaNowJudgment.productQueuedKicker(), tone: .active, showsDot: true)
                .accessibilityIdentifier(A11yID.arenaPremiumState("queued"))
            Text(ArenaNowJudgment.productQueuedTitle())
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityValue(ArenaNowFace.queued.productWord)
            Text(model.arenaLiveEngineTitle)
                .font(AtlasFont.mono(14))
                .foregroundStyle(AtlasTheme.textSecondary)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 28) {
                    queuedMetric("\(Set(queuedRuns.map(\.suite)).count)", "suítes")
                    queuedMetric("\(queuedRuns.count)", "corridas")
                    queuedMetric("\(Set(queuedRuns.compactMap { $0.arm?.rawValue }).count)", "braços")
                }
                VStack(alignment: .leading, spacing: 14) {
                    queuedMetric("\(Set(queuedRuns.map(\.suite)).count)", "suítes")
                    queuedMetric("\(queuedRuns.count)", "corridas")
                }
            }
            Text(ArenaNowJudgment.productQueuedHonestyLine())
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
            ArenaPremiumAction(title: "Ver execução", tone: .neutral) {
                onNavigate(.execution)
            }
            ArenaPremiumOperationalRows(model: model, onNavigate: onNavigate)
        }
    }

    private func queuedMetric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(AtlasFont.serif(32)).foregroundStyle(AtlasTheme.textPrimary)
            Text(label).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textSecondary)
        }
    }
}

// MARK: - Types

enum ArenaPremiumTerminalKind: Equatable {
    case stopping
    case stopped
    case completed
    case failed
}

struct ArenaPremiumTerminalView: View {
    @Bindable var model: ArenaModel
    let kind: ArenaPremiumTerminalKind
    let onRun: () -> Void
    let onNavigate: (ArenaPremiumDestination) -> Void

    /// WAVE-066: terminal chrome from ArenaNowJudgment.
    private var chrome: ArenaNowTerminalChrome {
        ArenaNowJudgment.terminalChrome(kind)
    }

    private var nowFace: ArenaNowFace {
        ArenaNowJudgment.face(terminal: kind)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumEmptyGlyph(symbol: chrome.symbol, tone: chrome.tone)
                .accessibilityIdentifier(A11yID.arenaPremiumState(stateIdentifier))
            ArenaPremiumKicker(text: chrome.title, tone: chrome.tone)
            Text(model.arenaLiveEngineTitle)
                .font(AtlasFont.serif(33))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(chrome.subtitle)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityValue(nowFace.productWord)
                .accessibilityLabel(nowFace.spokenFace)
            if let progress = model.livePresentation?.progress {
                HStack(alignment: .lastTextBaseline, spacing: 7) {
                    Text("\(progress.completed)")
                        .font(AtlasFont.serif(44))
                    Text("de \(progress.total) casos confirmados")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .foregroundStyle(AtlasTheme.textPrimary)
            }
            if kind == .failed {
                Text(publicFailureCopy)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.alert)
            }
            terminalActions
            ArenaPremiumOperationalRows(model: model, onNavigate: onNavigate)
        }
    }

    @ViewBuilder
    private var terminalActions: some View {
        if kind == .stopping {
            ArenaPremiumAction(
                title: "Parando…",
                symbol: "hourglass",
                tone: .active,
                disabled: true,
                action: {}
            )
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    ArenaPremiumAction(title: "Ver resultados", symbol: "chart.xyaxis.line", tone: .neutral) {
                        onNavigate(.results)
                    }
                    ArenaPremiumAction(title: "Rodar novamente", symbol: "arrow.clockwise", tone: .neutral, action: onRun)
                }
                VStack(alignment: .leading, spacing: 10) {
                    ArenaPremiumAction(title: "Ver resultados", symbol: "chart.xyaxis.line", tone: .neutral) {
                        onNavigate(.results)
                    }
                    ArenaPremiumAction(title: "Rodar novamente", symbol: "arrow.clockwise", tone: .neutral, action: onRun)
                }
            }
        }
    }

    private var publicFailureCopy: String {
        switch model.arenaPrimaryRun?.failureCode {
        case "with_atlas_runtime_unsupported": "este motor não suporta o braço com Atlas"
        case "plan_failed": "o plano da suíte não pôde ser preparado"
        case "native_execution_failed": "a execução nativa não concluiu"
        case "pipeline_failed": "a consolidação da medição falhou"
        case "internal_error": "falha interna classificada pelo servidor"
        default: "falha classificada pelo servidor"
        }
    }

    private var stateIdentifier: String {
        switch kind {
        case .stopping: "stopping"
        case .stopped: "stopped"
        case .completed: "completed"
        case .failed: "failed"
        }
    }
}

// MARK: - Primitives

// MARK: - Kicker

struct ArenaPremiumKicker: View {
    let text: String
    var tone: ArenaPremiumTone = .neutral
    /// Live: ✦ que respira (nunca bola). Demais kickers sem marca.
    var showsLiveMark = false

    var body: some View {
        HStack(spacing: 8) {
            if showsLiveMark {
                Text("✦")
                    .font(AtlasFont.serif(11))
                    .foregroundStyle(tone.color)
                    .modifier(ArenaLiveBreath())
                    .accessibilityHidden(true)
            }
            Text(text.uppercased())
                .font(AtlasFont.mono(10, .medium))
                .tracking(1.6)
                .foregroundStyle(tone.color)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Compat: kickers antigos com `showsDot:` viram marca ✦ quando true.
extension ArenaPremiumKicker {
    init(text: String, tone: ArenaPremiumTone = .neutral, showsDot: Bool) {
        self.init(text: text, tone: tone, showsLiveMark: showsDot)
    }
}

private struct ArenaLiveBreath: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var on = false

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion ? 1 : (on ? 1 : 0.55))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(AtlasMotion.breath(2.4)) { on = true }
            }
    }
}

// MARK: - Hairline · action

struct ArenaPremiumHairline: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [AtlasTheme.separator.opacity(0.2), AtlasTheme.separator, AtlasTheme.separator.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

struct ArenaPremiumAction: View {
    let title: String
    var symbol: String? = nil
    var tone: ArenaPremiumTone = .neutral
    var quiet = false
    var disabled = false
    let action: () -> Void

    /// Compat com call sites que passam SF Symbol.
    init(
        title: String,
        symbol: String,
        tone: ArenaPremiumTone = .neutral,
        quiet: Bool = false,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = symbol
        self.tone = tone
        self.quiet = quiet
        self.disabled = disabled
        self.action = action
    }

    init(
        title: String,
        tone: ArenaPremiumTone = .neutral,
        quiet: Bool = false,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = nil
        self.tone = tone
        self.quiet = quiet
        self.disabled = disabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .atlasSans(14, quiet ? .regular : .medium)
                .frame(maxWidth: .infinity, minHeight: 46)
                .padding(.horizontal, 20)
                .foregroundStyle(disabled ? AtlasTheme.textTertiary : (quiet ? AtlasTheme.textSecondary : AtlasTheme.textPrimary))
                .background(
                    Capsule().fill(
                        quiet || disabled
                            ? Color.clear
                            : Color.white.opacity(0.055)
                    )
                )
                .overlay(
                    Capsule().stroke(
                        quiet
                            ? AtlasTheme.separator.opacity(disabled ? 0.35 : 0.7)
                            : Color.white.opacity(disabled ? 0.04 : 0.08),
                        lineWidth: 1
                    )
                )
                .contentShape(Capsule())
        }
        .buttonStyle(PressableScale())
        .disabled(disabled)
        .accessibilityLabel(title)
    }
}

// MARK: - Disclosure · ring · empty

struct ArenaPremiumDisclosureRow: View {
    let title: String
    let detail: String
    let symbol: String
    var tone: ArenaPremiumTone = .neutral
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ArenaPremiumIcon(symbol: symbol, tone: tone)
                // Linha de lista fala sans (canon §C — serif é masthead/título);
                // mesma lei aplicada no Código e nos Artifacts hoje.
                Text(title)
                    .atlasSans(16, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer(minLength: 12)
                Text(detail)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(tone.color)
                    .lineLimit(1)
                ArenaPremiumChevron()
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ArenaPremiumProgressRing: View {
    let progress: Double?
    let percentage: Int?

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .trim(from: 0.08, to: 0.92)
                    .stroke(Color.white.opacity(0.06), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                if let progress {
                    Circle()
                        .trim(from: 0.08, to: 0.08 + 0.84 * min(max(progress, 0), 1))
                        .stroke(AtlasTheme.accent, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                }
            }
            .rotationEffect(.degrees(90))
            if let percentage {
                HStack(alignment: .lastTextBaseline, spacing: 1) {
                    Text("\(percentage)")
                        .font(AtlasFont.serif(42))
                    Text("%")
                        .font(AtlasFont.mono(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .baselineOffset(4)
                }
                .foregroundStyle(AtlasTheme.textPrimary)
            } else {
                Text("✦")
                    .font(AtlasFont.serif(24))
                    .foregroundStyle(AtlasTheme.accent)
            }
        }
        .frame(width: 142, height: 142)
        .accessibilityHidden(true)
    }
}

struct ArenaPremiumEmptyGlyph: View {
    let symbol: String
    var tone: ArenaPremiumTone = .neutral

    var body: some View {
        ArenaPremiumIcon(symbol: symbol, tone: tone, role: .hero)
            .background(Circle().fill(AtlasTheme.surface.opacity(0.72)))
            .overlay(Circle().stroke(AtlasTheme.separator, lineWidth: 1))
    }
}
// MARK: - ArenaPremiumIcon

enum ArenaPremiumIconRole {
    case compact
    case standard
    case hero

    var pointSize: CGFloat {
        switch self {
        case .compact: 12
        case .standard: 17
        case .hero: 28
        }
    }

    var box: CGFloat {
        switch self {
        case .compact: 16
        case .standard: 24
        case .hero: 68
        }
    }
}

/// The only renderer for symbols inside the Arena surface.
struct ArenaPremiumIcon: View {
    let symbol: String
    var tone: ArenaPremiumTone = .neutral
    var role: ArenaPremiumIconRole = .standard

    var body: some View {
        Image(systemName: symbol)
            .symbolRenderingMode(.monochrome)
            .font(.system(size: role.pointSize, weight: .medium))
            .foregroundStyle(tone.color)
            .frame(width: role.box, height: role.box, alignment: .center)
            .accessibilityHidden(true)
    }
}

struct ArenaPremiumChevron: View {
    var body: some View {
        ArenaPremiumIcon(
            symbol: ArenaPremiumIconography.disclosure,
            tone: .muted,
            role: .compact
        )
    }
}

enum ArenaPremiumIconography {
    static let action = "play.fill"
    static let add = "plus"
    static let alerts = "exclamationmark.triangle"
    static let blocked = "lock"
    static let comparison = "arrow.right"
    static let coverage = "checkmark.seal"
    static let disclosure = "chevron.right"
    static let execution = "list.bullet.rectangle"
    static let next = "calendar.badge.clock"
    static let plan = "list.bullet.rectangle"
    static let queue = "tray.full"
    static let stop = "stop.fill"

    static func run(_ status: AtlasArenaRunStatus) -> String {
        ArenaRunStatusJudgment.sfSymbol(for: status)
    }

    static func planStatus(_ status: AtlasArenaRunStatus?) -> String {
        guard let status else { return "circle" }
        return ArenaRunStatusJudgment.sfSymbol(for: status)
    }

    static func suite(_ suite: String) -> String {
        switch suite {
        case "terminal_bench": "terminal"
        case "bfcl": "wrench.and.screwdriver"
        case "inspect_evals": "arrow.triangle.2.circlepath"
        case "tau2_bench": "function"
        case "live_code_bench", "swe_bench_live":
            "chevron.left.forwardslash.chevron.right"
        default: "diamond"
        }
    }
}
// MARK: - ArenaPremiumTabBar

struct ArenaPremiumTabBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var selection: ArenaPremiumTab
    @Namespace private var selectionNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ArenaPremiumTab.allCases) { tab in
                Button {
                    withAnimation(reduceMotion ? nil : AtlasMotion.editorial) { selection = tab }
                } label: {
                    // Controle fala sans (canon §C); seleção = pílula neutra
                    // ELEVADA (padrão do segmented nativo), não véu de ouro —
                    // ouro é ESTADO, não seleção de controle.
                    Text(tab.rawValue)
                        .atlasSans(13, .medium)
                        .foregroundStyle(selection == tab ? AtlasTheme.textPrimary : AtlasTheme.textTertiary)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background {
                            if selection == tab {
                                Capsule()
                                    .fill(AtlasTheme.surfaceHi)
                                    .shadow(color: .black.opacity(0.22), radius: 5, y: 1)
                                    .matchedGeometryEffect(id: "arena-tab", in: selectionNamespace)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tabAccessibilityLabel(tab))
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
                .accessibilityIdentifier(A11yID.arenaPremiumTab(tab.a11yKey))
            }
        }
        .padding(3)
        .background(Capsule().fill(AtlasTheme.bgRecessed.opacity(0.92)))
        .overlay(Capsule().stroke(AtlasTheme.separator.opacity(0.7), lineWidth: 1))
    }

    private func tabAccessibilityLabel(_ tab: ArenaPremiumTab) -> String {
        switch tab {
        case .now: "Agora"
        case .fleet: "Frota"
        case .capabilities: "Capacidades"
        case .results: "Motor"
        }
    }
}
// MARK: - ArenaPremiumChrome

struct ArenaPremiumEngineTitle: View {
    let engineID: String
    let options: [String]
    let onSelect: (String) -> Void

    var body: some View {
        if options.count > 1 {
            Menu {
                ForEach(options, id: \.self) { engine in
                    Button {
                        onSelect(engine)
                    } label: {
                        if engine == engineID {
                            Label(ArenaDisplay.engine(engine), systemImage: "checkmark")
                        } else {
                            Text(ArenaDisplay.engine(engine))
                        }
                    }
                }
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(ArenaDisplay.engine(engineID))
                        .font(AtlasFont.serif(33))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .accessibilityLabel(ArenaScoreJudgment.spokenMeasuredEngine(engineID))
            .accessibilityHint(ArenaScoreJudgment.spokenMeasuredEngineHint)
            .accessibilityIdentifier(A11yID.arenaPremiumEnginePicker)
        } else {
            Text(ArenaDisplay.engine(engineID))
                .font(AtlasFont.serif(33))
                .foregroundStyle(AtlasTheme.textPrimary)
        }
    }
}
// MARK: - ArenaPremiumLoadFailureView

struct ArenaPremiumLoadFailureView: View {
    @Bindable var model: ArenaModel

    var body: some View {
        AtlasOpsFailureEmpty(
            mode: model.isDomainUnavailable
                ? .domainUnavailable
                : .load(
                    headline: "Não foi possível carregar a medição",
                    message: "A tela não transformou a falha de rede em estado vazio."
                ),
            layout: .leadingEditorial,
            kicker: model.isDomainUnavailable ? "Arena não publicada" : "Arena indisponível",
            symbol: model.isDomainUnavailable ? "shippingbox" : "wifi.exclamationmark",
            topPadding: 0,
            accessibilityIdentifier: A11yID.arenaPremiumState("failed-load"),
            retryHint: ArenaNowJudgment.spokenReloadArenaHint,
            onRetry: { Task { await model.load() } }
        )
    }
}
// MARK: - ArenaPremiumGlyphRow

struct ArenaPremiumGlyphRow: View {
    let glyph: String
    let title: String
    let detail: String
    var tone: ArenaPremiumTone = .neutral
    var glyphTone: ArenaPremiumTone? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(glyph)
                    .font(AtlasFont.serif(14))
                    .foregroundStyle((glyphTone ?? tone).color)
                    .frame(width: 22, alignment: .center)
                    .accessibilityHidden(true)
                Text(title)
                    .atlasSans(16, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer(minLength: 12)
                Text(detail)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(tone.color)
                    .lineLimit(1)
                Text("›")
                    .font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ArenaPremiumOperationalRows: View {
    @Bindable var model: ArenaModel
    let onNavigate: (ArenaPremiumDestination) -> Void

    private var alertCount: Int { model.arenaAlertSuiteCount }

    var body: some View {
        // Sem exceção: some a seção. Fila/Cobertura/Próxima/Plano moram
        // DENTRO de Execução — duplicar aqui era a confusão.
        if alertCount > 0 {
            VStack(spacing: 0) {
                ArenaPremiumHairline()
                ArenaPremiumGlyphRow(
                    glyph: "※",
                    title: "Alertas",
                    detail: alertCount == 1 ? "1 exceção" : "\(alertCount) exceções",
                    tone: .negative,
                    glyphTone: .negative
                ) { onNavigate(.alerts) }
                .accessibilityIdentifier(A11yID.arenaPremiumAlertsAction)
            }
        }
    }
}
// MARK: - ArenaToggleSymbolBounce

struct ArenaToggleSymbolBounce: ViewModifier {
    let enabled: Bool
    let isOn: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.symbolEffect(.bounce, value: isOn)
        } else {
            content
        }
    }
}
// MARK: - ArenaFormat

enum ArenaFormat {
    private static let scoreStyle = FloatingPointFormatStyle<Double>.number
        .locale(Locale(identifier: "pt_BR"))
        .grouping(.never)
        .precision(.fractionLength(0...1))

    private static let multiplierStyle = FloatingPointFormatStyle<Double>.number
        .locale(Locale(identifier: "pt_BR"))
        .grouping(.never)
        .precision(.fractionLength(2))

    static func score(_ value: Double?) -> String {
        guard let value = AtlasArenaPresentationScale.score(value) else {
            return "não medido"
        }
        return value.formatted(scoreStyle)
    }

    static func signed(_ value: Double?) -> String {
        guard let value = AtlasArenaPresentationScale.delta(value) else {
            return "—"
        }
        if abs(value) < 0.05 {
            return "0"
        }
        return "\(value > 0 ? "+" : "")\(value.formatted(scoreStyle))"
    }

    static func multiplier(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "×\(value.formatted(multiplierStyle))"
    }
}
// MARK: - ArenaSuiteSparkline

extension AtlasArenaSuite {
    var arenaSubtitleText: String {
        guard isMeasured else { return "não medido" }
        let rounds = runsTotal == 1 ? "1 rodada" : "\(runsTotal) rodadas"
        if let relative = ArenaDisplay.relative(lastRunAt) { return "\(rounds) · \(relative)" }
        return rounds
    }
}

struct SuiteSparkline: View {
    let engine: AtlasArenaSuiteEngine

    var body: some View {
        Chart(engine.history) { point in
            if let score = point.score {
                LineMark(x: .value("rodada", point.roundAt), y: .value("score", score))
                    .foregroundStyle(point.arm == .withAtlas ? AtlasTheme.accent : AtlasTheme.textSecondary)
                    .interpolationMethod(.linear)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .accessibilityHidden(true)
    }
}

// MARK: - Composite chart

struct ArenaCompositeChart: View {
    let engine: AtlasArenaCompositeEngine
    let reduceMotion: Bool

    var interpolation: InterpolationMethod { reduceMotion ? .linear : .catmullRom }

    var body: some View {
        Chart {
            historyMarks
        }
        .chartLegend(.visible)
        .chartXAxis(.hidden)
        .chartYScale(domain: fittedYDomain)
        .chartYAxis { AxisMarks(position: .leading) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteJudgment.spokenCompositeChart(engine))
    }

    /// Domínio ajustado ao dado: eixo fixo 0–1 espremia as linhas.
    var fittedYDomain: ClosedRange<Double> {
        let values = engine.history.flatMap { [$0.composite, $0.withAtlas, $0.withoutAtlas].compactMap { $0 } }
        guard let lo = values.min(), let hi = values.max(), hi > lo else { return 0 ... 1 }
        let pad = max(0.04, (hi - lo) * 0.3)
        return max(0, lo - pad) ... min(1, hi + pad)
    }

    @ChartContentBuilder
    var historyMarks: some ChartContent {
        ForEach(engine.history) { point in
            if let composite = point.composite {
                LineMark(x: .value("rodada", point.roundAt), y: .value("composto", composite))
                    .foregroundStyle(AtlasTheme.accent)
                    .interpolationMethod(interpolation)
            }
            if let withAtlas = point.withAtlas {
                LineMark(
                    x: .value("rodada", point.roundAt),
                    y: .value("com Atlas", withAtlas),
                    series: .value("série", "com Atlas")
                )
                .foregroundStyle(AtlasTheme.accent.opacity(0.65))
                .interpolationMethod(interpolation)
            }
            if let withoutAtlas = point.withoutAtlas {
                LineMark(
                    x: .value("rodada", point.roundAt),
                    y: .value("sem Atlas", withoutAtlas),
                    series: .value("série", "sem Atlas")
                )
                .foregroundStyle(AtlasTheme.textSecondary)
                .interpolationMethod(interpolation)
            }
        }
    }
}

// MARK: - ArenaDisplay

enum ArenaDisplay {
    private static let engines: [String: String] = [
        "claude_opus_4_8": "Claude Opus 4.8",
        "claude_sonnet_5": "Claude Sonnet 5",
        "codex_gpt_5_5": "Codex · GPT-5.5",
        "codex_cli": "Codex CLI",
        "claude_code": "Claude Code",
        "gemini": "Gemini",
        "minimax_m3": "MiniMax M3",
        "verboo_qwen_3_6_27b": "Qwen 3.6 27B · Verboo",
        "verboo_kimi_k2_7": "Kimi K2.7 · Verboo",
        "glm_5_2": "GLM 5.2",
        "hermes": "Hermes",
    ]

    private static let suites: [String: String] = [
        "terminal_bench": "Terminal Bench",
        "inspect_evals": "Inspect Evals",
        "tau2_bench": "τ²-Bench",
        "bfcl": "BFCL · Funções",
        "senior_swe_bench": "Senior SWE",
        "swe_bench_live": "SWE Live",
        "live_code_bench": "LiveCodeBench",
        "hal_harness": "HAL Harness",
        "aider_polyglot": "Aider Polyglot",
        "swe_marathon": "SWE Marathon",
        "testeval": "TestEval",
    ]

    static func engine(_ id: String) -> String {
        engines[id] ?? humanized(id)
    }

    /// 78778ms → "1min 19s"; 6201ms → "6,2s"; 320ms → "320ms".
    static func duration(ms: Int) -> String {
        if ms < 1000 { return "\(ms)ms" }
        let seconds = Double(ms) / 1000
        if seconds < 60 {
            return String(format: "%.1fs", seconds).replacingOccurrences(of: ".", with: ",")
        }
        let minutes = Int(seconds) / 60
        let rest = Int(seconds) % 60
        return rest == 0 ? "\(minutes)min" : "\(minutes)min \(rest)s"
    }

    /// Origem do run (`iphone|ipad|mac|cli`) → rótulo humano; nil = não dita.
    static func origin(_ id: String?) -> String? {
        switch id {
        case "iphone": return "iPhone"
        case "ipad": return "iPad"
        case "mac": return "Mac"
        case "cli": return "CLI"
        default: return nil
        }
    }

    static func suite(_ id: String) -> String {
        suites[id] ?? humanized(id)
    }

    /// Fallback genérico: snake_case → Palavras Capitalizadas.
    private static func humanized(_ id: String) -> String {
        id.split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    /// "2026-07-16T23:42:29+00:00" → "há 2h"; nil se não parsear (nunca ISO cru).
    static func relative(_ isoString: String?) -> String? {
        guard let date = AtlasTime.date(isoString) else { return nil }
        let seconds = max(0, Int(Date().timeIntervalSince(date)))
        switch seconds {
        case ..<60: return "agora"
        case ..<3600: return "há \(seconds / 60)min"
        case ..<86_400: return "há \(seconds / 3600)h"
        default: return "há \(seconds / 86_400)d"
        }
    }
}

// MARK: - Types

enum ArenaPremiumTab: String, CaseIterable, Identifiable {
    case now = "Agora"
    case fleet = "Frota"
    case capabilities = "Capac."
    case results = "Motor"

    var id: String { rawValue }

    /// Identificador estável p/ a11y (não depende do rótulo curto da aba).
    var a11yKey: String {
        switch self {
        case .now: "agora"
        case .fleet: "frota"
        case .capabilities: "capacidades"
        case .results: "motor"
        }
    }
}

enum ArenaPremiumDestination: String, Identifiable, Hashable {
    case execution
    case plan
    case queue
    case alerts
    case results

    var id: String { rawValue }
}

enum ArenaPremiumTone {
    case muted
    case neutral
    case active
    case positive
    case negative

    var color: Color {
        switch self {
        case .muted: AtlasTheme.textTertiary
        case .neutral: AtlasTheme.textSecondary
        case .active: AtlasTheme.accent
        case .positive: AtlasTheme.textPrimary
        case .negative: AtlasTheme.alert
        }
    }
}

extension ArenaModel {
    var arenaSelectedEngineID: String? {
        capabilitiesEngineSelection ?? composite?.engines.first?.engine
    }

    var arenaPrimaryEngine: AtlasArenaCompositeEngine? {
        guard let selected = arenaSelectedEngineID else { return composite?.engines.first }
        return composite?.engines.first { $0.engine == selected }
            ?? composite?.engines.first
    }

    var arenaPrimaryRun: AtlasArenaLiveRun? {
        livePresentation?.primaryRun
    }

    var arenaPrimarySuite: AtlasArenaSuite? {
        guard let run = arenaPrimaryRun else { return scoreboard?.suites.first }
        return scoreboard?.suites.first { $0.suite == run.suite }
    }

    var arenaPrimaryMeasurementRuns: [AtlasArenaLiveRun] {
        guard let primary = arenaPrimaryRun else { return [] }
        guard let measurement = primary.measurementIdPublic else { return [primary] }
        return liveRuns?.runs.filter { $0.measurementIdPublic == measurement } ?? [primary]
    }

    var arenaRegressionCount: Int {
        scoreboard?.suites.filter(\.hasRegression).count ?? 0
    }

    var arenaCoverageText: String {
        guard let composite else { return "não medida" }
        return "\(composite.suitesMeasured)/\(composite.suitesTotal) suítes"
    }

    var arenaAlertSuiteCount: Int {
        var suites = Set(scoreboard?.suites.filter(\.hasRegression).map(\.suite) ?? [])
        suites.formUnion(report?.attentionSuites.map(\.suite) ?? [])
        return suites.count
    }

    /// Título humano do motor ao vivo — nunca o literal "motor desconhecido".
    var arenaLiveEngineTitle: String {
        if let id = arenaPrimaryRun?.engine, !id.isEmpty {
            return ArenaDisplay.engine(id)
        }
        if let preferred = preferredEngine, !preferred.isEmpty {
            return ArenaDisplay.engine(preferred)
        }
        if let composite = arenaPrimaryEngine?.engine {
            return ArenaDisplay.engine(composite)
        }
        return "Medição ao vivo"
    }
}
