import SwiftUI
import AtlasCore

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
                invite: ArenaPremiumAskContext.invite(tab: selectedTab, destination: destination),
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
            emptyPrompt: ArenaPremiumAskContext.invite(tab: selectedTab, destination: destination),
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
            .accessibilityLabel(ArenaStartJudgment.newMeasurementLabel)
            .accessibilityHint("Escolhe motores, suítes e braços")
            .accessibilityIdentifier(A11yID.arenaPremiumAdd)
        }
    }
}

// MARK: - Entry AtlasArenaView

extension AtlasArenaView {
    func arenaLifecycleA11y<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Arena")
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
            ArenaPremiumKicker(text: ArenaNowJudgment.preparingKicker(), tone: .active, showsDot: true)
            Text(ArenaNowJudgment.preparingTitle())
                .font(AtlasFont.serif(32))
                .foregroundStyle(AtlasTheme.textPrimary)
            ProgressView()
                .tint(AtlasTheme.accent)
            Text("Índice, execução e capacidades chegam por contratos independentes.")
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
            ArenaPremiumKicker(text: ArenaNowJudgment.idleKicker())
            Text(ArenaNowJudgment.idleTitle())
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(ArenaNowJudgment.idleBody())
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
            ArenaPremiumKicker(text: ArenaNowJudgment.queuedKicker(), tone: .active, showsDot: true)
                .accessibilityIdentifier(A11yID.arenaPremiumState("queued"))
            Text(ArenaNowJudgment.queuedTitle())
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
            Text(ArenaNowJudgment.queuedHonestyLine())
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
