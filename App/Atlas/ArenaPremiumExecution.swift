import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: Arena execution surface (file not route shell)

// MARK: - Execution host

struct ArenaPremiumExecutionView: View {
    @Bindable var model: ArenaModel
    let onStop: (AtlasArenaLiveRun) -> Void

    private var runs: [AtlasArenaLiveRun] { model.arenaPrimaryMeasurementRuns }
    private var primary: AtlasArenaLiveRun? { model.arenaPrimaryRun }

    /// WAVE-050: pure live-control rank (live → failed → done → queued).
    private var orderedRuns: [AtlasArenaLiveRun] {
        ArenaLiveControlJudgment.rank(runs)
    }

    private var liveFace: ArenaLiveControlFace {
        ArenaLiveControlJudgment.face(runs: runs, primary: primary)
    }

    private var pipeline: ArenaPremiumPipelineProjection {
        let planArms = model.activePlan?.arms ?? []
        return .project(
            runs: runs,
            expectsBare: planArms.contains(.baseline) || runs.contains { $0.arm == .baseline },
            expectsAtlas: planArms.contains(.withAtlas) || runs.contains { $0.arm == .withAtlas },
            hasReport: model.report != nil
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
                .accessibilityIdentifier(A11yID.arenaPremiumExecution)
            nowBlock
            if canStop {
                ArenaPremiumAction(title: "Parar após o caso atual", quiet: true) {
                    if let primary { onStop(primary) }
                }
            }
            ArenaPremiumHairline()
            ArenaPremiumExecutionPipeline(projection: pipeline)
            ArenaPremiumHairline()
            corridas
        }
    }

    private var canStop: Bool {
        ArenaLiveControlJudgment.canStop(primary: primary)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: statusLabel,
                tone: statusTone,
                showsLiveMark: statusTone == .active
            )
            Text(model.arenaLiveEngineTitle)
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text("Ordem, estado e progresso confirmados pelo servidor.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    @ViewBuilder
    private var nowBlock: some View {
        if let primary {
            let casesDone = primary.casesDone
            let casesTotal = primary.casesTotal
            if let casesDone, let casesTotal, casesTotal > 0 {
                caseHero(
                    done: min(casesDone, casesTotal),
                    total: casesTotal,
                    fraction: Double(min(max(0, casesDone), casesTotal)) / Double(casesTotal),
                    suiteLine: suiteLine(primary)
                )
            } else if let progress = model.livePresentation?.progress {
                caseHero(
                    done: progress.completed,
                    total: progress.total,
                    fraction: progress.fraction,
                    suiteLine: suiteLine(primary)
                )
            } else {
                Text("Casos ainda sem denominador nesta corrida.")
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        } else if runs.isEmpty {
            Text("Nenhuma corrida nesta medição.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func caseHero(done: Int, total: Int, fraction: Double, suiteLine: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(done)")
                    .font(AtlasFont.serif(52))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("de \(total) casos")
                    .font(AtlasFont.serif(22))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Spacer()
                Text("\(Int((fraction * 100).rounded(.down)))%")
                    .font(AtlasFont.mono(18, .medium))
                    .foregroundStyle(AtlasTheme.accent)
            }
            Text(suiteLine)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func suiteLine(_ run: AtlasArenaLiveRun) -> String {
        [ArenaDisplay.suite(run.suite), run.arm?.labelPT]
            .compactMap(\.self)
            .joined(separator: " · ")
    }

    private var corridas: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Corridas")
                .font(AtlasFont.mono(10, .medium))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
                .padding(.bottom, 10)
            if orderedRuns.isEmpty {
                Text("Ainda sem corridas publicadas.")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
            } else {
                ForEach(orderedRuns) { run in
                    NavigationLink {
                        ArenaPremiumRunDetailView(run: run)
                    } label: {
                        runRow(run)
                    }
                    .buttonStyle(.plain)
                    ArenaPremiumHairline()
                }
            }
        }
    }

    private func runRow(_ run: AtlasArenaLiveRun) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            Text(ArenaRunStatusJudgment.rowGlyph(for: run.status))
                .font(AtlasFont.serif(14))
                .foregroundStyle(ArenaRunStatusJudgment.tone(for: run.status).color)
                .frame(width: 22, alignment: .center)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(ArenaDisplay.suite(run.suite))
                    .atlasSans(16, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(ArenaRunStatusJudgment.rowDetail(run))
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            Spacer(minLength: 8)
            Text(ArenaRunStatusJudgment.rowTrailing(run))
                .font(AtlasFont.mono(11, .medium))
                .foregroundStyle(ArenaRunStatusJudgment.tone(for: run.status).color)
                .multilineTextAlignment(.trailing)
            ArenaPremiumChevron()
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .accessibilityIdentifier(A11yID.arenaPremiumExecutionRun(run.runIdPublic))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(ArenaDisplay.suite(run.suite)), \(run.arm?.labelPT ?? ""), \(ArenaRunStatusJudgment.rowTrailing(run))"
        )
        .accessibilityHint("Abre os casos desta corrida")
    }

    private var statusLabel: String {
        // WAVE-050: live-control face elevates failed attention over generic done.
        switch liveFace {
        case .running: return ArenaRunStatusJudgment.productLabel(for: .running)
        case .stopping: return ArenaRunStatusJudgment.productLabel(for: .stopping)
        case .attention: return liveFace.kicker
        case .queued: return ArenaRunStatusJudgment.productLabel(for: .queued)
        case .quietDone:
            switch model.livePresentation?.phase ?? .idle {
            case .completed: return ArenaRunStatusJudgment.productLabel(for: .completed)
            case .stopped: return ArenaRunStatusJudgment.productLabel(for: .stopped)
            case .failed: return "Interrompida"
            default: return "Encerrada"
            }
        case .empty:
            return "Sem execução"
        }
    }

    private var statusTone: ArenaPremiumTone {
        switch liveFace {
        case .running, .stopping, .queued: return .active
        case .attention: return .negative
        case .quietDone:
            if model.livePresentation?.phase == .completed {
                return ArenaRunStatusJudgment.tone(for: .completed)
            }
            return .neutral
        case .empty: return .neutral
        }
    }
}
// MARK: - ArenaPremiumExecutionPipeline

enum ArenaPremiumPipelineStep: Int, CaseIterable, Identifiable {
    case prepare
    case bare
    case withAtlas
    case consolidate

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .prepare: "Preparar"
        case .bare: "Sem Atlas"
        case .withAtlas: "Com Atlas"
        case .consolidate: "Consolidar"
        }
    }
}

enum ArenaPremiumPipelineMark {
    case pending
    case live
    case done
}

struct ArenaPremiumPipelineProjection: Equatable {
    let marks: [ArenaPremiumPipelineStep: ArenaPremiumPipelineMark]

    /// WAVE-109: projection law lives on ArenaPipelineJudgment.
    static func project(
        runs: [AtlasArenaLiveRun],
        expectsBare: Bool,
        expectsAtlas: Bool,
        hasReport: Bool
    ) -> ArenaPremiumPipelineProjection {
        ArenaPipelineJudgment.project(
            runs: runs,
            expectsBare: expectsBare,
            expectsAtlas: expectsAtlas,
            hasReport: hasReport
        )
    }
}

struct ArenaPremiumExecutionPipeline: View {
    let projection: ArenaPremiumPipelineProjection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pipeline")
                .font(AtlasFont.mono(10, .medium))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
            HStack(alignment: .top, spacing: 0) {
                ForEach(ArenaPremiumPipelineStep.allCases) { step in
                    stepColumn(step)
                    if step != .consolidate {
                        pipelineRail(after: step)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ArenaPipelineJudgment.spoken(projection))
        .accessibilityIdentifier(A11yID.arenaPremiumExecutionPipeline)
    }

    private func stepColumn(_ step: ArenaPremiumPipelineStep) -> some View {
        let mark = projection.marks[step] ?? .pending
        return VStack(spacing: 8) {
            Text(ArenaPipelineJudgment.glyph(step: step, mark: mark))
                .font(AtlasFont.serif(14))
                .foregroundStyle(ArenaPipelineJudgment.color(for: mark))
                .frame(height: 20)
            Text(step.title)
                .font(AtlasFont.mono(9, .medium))
                .foregroundStyle(mark == .pending ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private func pipelineRail(after step: ArenaPremiumPipelineStep) -> some View {
        let done = (projection.marks[step] ?? .pending) == .done
        return Rectangle()
            .fill(done ? AtlasTheme.separator : AtlasTheme.separator.opacity(0.35))
            .frame(width: 18, height: 1)
            .padding(.top, 10)
            .accessibilityHidden(true)
    }
}
// MARK: - ArenaPremiumRunningView

struct ArenaPremiumRunningView: View {
    @Bindable var model: ArenaModel
    let onNavigate: (ArenaPremiumDestination) -> Void
    let onStop: (AtlasArenaLiveRun) -> Void

    private var run: AtlasArenaLiveRun? { model.arenaPrimaryRun }
    private var progress: AtlasArenaLiveProgress? { model.livePresentation?.progress }
    private var percentage: Int? {
        progress.flatMap { $0.completed == 0 ? nil : Int(($0.fraction * 100).rounded(.down)) }
    }

    /// Nunca “Motor desconhecido”: se o live run veio sem engine, usa o
    /// preferido / composto. O string literal do Core é falha de wire, não UX.
    private var engineTitle: String { model.arenaLiveEngineTitle }

    private var subtitle: String {
        [run.map { ArenaDisplay.suite($0.suite) }, run?.arm?.labelPT]
            .compactMap(\.self)
            .joined(separator: " · ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            identity
            progressHero
            actions
            ArenaPremiumComparison(model: model, provisional: true)
            ArenaPremiumOperationalRows(model: model, onNavigate: onNavigate)
        }
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(text: "Ao vivo", tone: .active, showsLiveMark: true)
                .accessibilityIdentifier(A11yID.arenaPremiumState("running"))
            Text(engineTitle)
                .font(AtlasFont.serif(31))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
    }

    private var progressHero: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 24) {
                ArenaPremiumProgressRing(progress: progress?.fraction, percentage: percentage)
                progressCopy
                    .frame(minHeight: 142, alignment: .center)
            }
            VStack(alignment: .leading, spacing: 14) {
                ArenaPremiumProgressRing(progress: progress?.fraction, percentage: percentage)
                progressCopy
            }
        }
    }

    private var progressCopy: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let progress {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(progress.completed)")
                        .font(AtlasFont.serif(28))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("/ \(progress.total)")
                        .font(AtlasFont.serif(18))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                Text("casos confirmados")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Text("\(progress.remaining) restantes")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 2)
            } else {
                Text("Progresso indeterminado")
                    .font(AtlasFont.mono(13, .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("denominador ainda não publicado")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumAction(title: "Ver execução", tone: .neutral) {
                onNavigate(.execution)
            }
            .accessibilityIdentifier(A11yID.arenaPremiumExecutionAction)
            // WAVE-083: single canStop law = ArenaLiveControlJudgment.
            if let run, ArenaLiveControlJudgment.canStop(primary: run) {
                ArenaPremiumAction(title: "Parar após o caso atual", quiet: true) {
                    onStop(run)
                }
                .accessibilityIdentifier(A11yID.arenaPremiumStop)
            }
        }
    }
}
// MARK: - ArenaPremiumRunDetailView

struct ArenaPremiumRunDetailView: View {
    let run: AtlasArenaLiveRun

    private var fraction: Double? {
        guard let done = run.casesDone, let total = run.casesTotal, total > 0 else { return nil }
        return Double(min(max(0, done), total)) / Double(total)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                progressBlock
                casesBlock
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 18)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle(ArenaDisplay.suite(run.suite))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier(A11yID.arenaPremiumRunDetail)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: statusLabel,
                tone: statusTone,
                showsLiveMark: run.status == .running || run.status == .stopping
            )
            Text(ArenaDisplay.suite(run.suite))
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.textPrimary)
            if let arm = run.arm?.labelPT {
                Text(arm)
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var progressBlock: some View {
        if let done = run.casesDone, let total = run.casesTotal, total > 0, let fraction {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text("\(min(done, total))")
                        .font(AtlasFont.serif(44))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("de \(total) casos")
                        .font(AtlasFont.serif(18))
                        .foregroundStyle(AtlasTheme.textSecondary)
                    Spacer()
                    Text("\(Int((fraction * 100).rounded(.down)))%")
                        .font(AtlasFont.mono(16, .medium))
                        .foregroundStyle(AtlasTheme.accent)
                }
                Text(summaryLine(done: min(done, total), total: total))
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        } else {
            Text("Denominador de casos ainda não publicado nesta corrida.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private var casesBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Casos")
                .font(AtlasFont.mono(10, .medium))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
            Text("Lista por teste ainda não publicada pelo servidor. Quando o contrato chegar, cada caso aparece aqui — feitos, ao vivo e a seguir.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier(A11yID.arenaPremiumRunDetailCases)
    }

    private func summaryLine(done: Int, total: Int) -> String {
        ArenaRunStatusJudgment.casesSummaryLine(
            status: run.status,
            done: done,
            total: total
        )
    }

    private var statusLabel: String {
        ArenaRunStatusJudgment.productLabel(for: run.status)
    }

    private var statusTone: ArenaPremiumTone {
        ArenaRunStatusJudgment.tone(for: run.status)
    }
}
// MARK: - ArenaPremiumDestinationView

struct ArenaPremiumDestinationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AtlasSession.self) private var session
    let target: ArenaPremiumDestination
    @Bindable var model: ArenaModel
    let onStop: (AtlasArenaLiveRun) -> Void
    let onSuite: (AtlasArenaSuite) -> Void
    @State private var showingAsk = false
    @State private var askThreadId: ThreadID?
    @State private var askDraft = ""

    var body: some View {
        ScrollView {
            destinationContent
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 18)
                .padding(.bottom, 108)
        }
        .scrollIndicators(.hidden)
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AgenticAskDock {
                AgenticPill(
                    invite: ArenaPremiumAskContext.invite(
                        tab: ArenaPremiumAskContext.tabForDestination(target),
                        destination: target
                    ),
                    accessibilityId: A11yID.arenaPremiumAskPill
                ) {
                    askDraft = ""
                    showingAsk = true
                }
            }
        }
        .sheet(isPresented: $showingAsk) {
            ConversationView(
                client: session.client,
                threadId: askThreadId,
                title: "Arena · \(title)",
                emptyPrompt: ArenaPremiumAskContext.invite(
                    tab: ArenaPremiumAskContext.tabForDestination(target),
                    destination: target
                ),
                emptySuggestions: ArenaPremiumAskContext.emptySuggestions(
                    tab: ArenaPremiumAskContext.tabForDestination(target),
                    destination: target
                ),
                taskKind: "arena",
                workspace: nil,
                draft: askDraft,
                turnFacts: { [model, target] _ in
                    ArenaPremiumAskContext.facts(
                        model: model,
                        tab: ArenaPremiumAskContext.tabForDestination(target),
                        destination: target
                    )
                },
                onThread: { askThreadId = $0 },
                hidesNavigationBack: true
            )
            .agenticAskSheetPresentation()
        }
    }

    @ViewBuilder
    private var destinationContent: some View {
        switch target {
        case .execution:
            ArenaPremiumExecutionView(model: model, onStop: onStop)
        case .plan:
            ArenaPremiumPlanView(model: model)
        case .queue:
            ArenaPremiumQueueView(model: model)
        case .alerts:
            ArenaPremiumAlertsView(model: model, onSuite: onSuite)
        case .results:
            ArenaPremiumResultsView(
                model: model,
                reduceMotion: reduceMotion,
                onSuite: onSuite
            )
        }
    }

    private var title: String {
        switch target {
        case .execution: "Execução"
        case .plan: "Plano"
        case .queue: "Fila"
        case .alerts: "Alertas"
        case .results: "Motor"
        }
    }
}

// MARK: - ArenaPremiumAskContext

enum ArenaPremiumAskContext {
    // MARK: - Invite / empty

    static func invite(tab: ArenaPremiumTab, destination: ArenaPremiumDestination?) -> String {
        if let destination {
            switch destination {
            case .execution: return "pergunte sobre esta execução"
            case .queue: return "pergunte sobre a fila"
            case .alerts: return "pergunte sobre estes alertas"
            case .plan: return "pergunte sobre este plano"
            case .results: return "pergunte sobre este motor"
            }
        }
        switch tab {
        case .now: return "pergunte sobre esta medição"
        case .fleet: return "pergunte sobre a frota medida"
        case .capabilities: return "pergunte sobre estas capacidades"
        case .results: return "pergunte sobre este motor"
        }
    }

    /// Suggestions calibradas ao can-do atual (NL chat = leitura; run/stop = CTA).
    static func emptySuggestions(
        tab: ArenaPremiumTab,
        destination: ArenaPremiumDestination? = nil
    ) -> [String] {
        if let destination {
            switch destination {
            case .execution:
                return [
                    "Como está o progresso da execução?",
                    "Onde o Atlas está ganhando nestas corridas?",
                    "Qual corrida precisa de atenção?"
                ]
            case .queue:
                return [
                    "O que está na fila?",
                    "Qual suíte vem a seguir?",
                    "Há bloqueio na fila?"
                ]
            case .alerts:
                return [
                    "Quais alertas importam agora?",
                    "Onde o Atlas regressou?",
                    "Qual suíte abriu exceção?"
                ]
            case .plan:
                return [
                    "Resuma o plano de medição",
                    "O que falta no plano?",
                    "Há plano ativo real?"
                ]
            case .results:
                return [
                    "Explica o índice deste motor",
                    "Quais suítes puxaram o ganho?",
                    "Onde a cobertura é parcial?"
                ]
            }
        }
        switch tab {
        case .now:
            return [
                "Como está o progresso agora?",
                "Onde o Atlas está ganhando nesta medição?",
                "Qual o status ao vivo?"
            ]
        case .fleet:
            return [
                "Qual motor sobe mais com Atlas?",
                "Onde o Atlas regressa na frota?",
                "Compara os motores medidos"
            ]
        case .capabilities:
            return [
                "Quais capacidades regrediram?",
                "Onde o Atlas sobe neste perfil?",
                "Resumo das capacidades cobertas"
            ]
        case .results:
            return [
                "Explica o índice deste motor",
                "Quais suítes puxaram o ganho?",
                "Onde a cobertura é parcial?"
            ]
        }
    }

    /// Pack WAVE-020 — tab **e** destination (nunca forçar Agora em destinos).
    // MARK: - Shell pack (WAVE-186)

    /// Arena shell identity — tela/aba · cobertura · engine anchor only.
    static func packShellFacts(
        tab: ArenaPremiumTab,
        destination: ArenaPremiumDestination?,
        coverageText: String,
        primaryEngineLabel: String?
    ) -> (facts: [String], absences: [String], anchors: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        var anchors: [String] = []
        if let destination {
            facts.append("tela: \(destinationLabel(destination))")
            anchors.append("dest: \(destinationLabel(destination))")
        } else {
            facts.append("aba: \(tab.rawValue)")
            anchors.append("tab: \(tab.rawValue)")
        }
        if let primaryEngineLabel {
            anchors.append("engine: \(primaryEngineLabel)")
        }
        facts.append("cobertura_texto: \(coverageText)")
        absences.append("não invente scores; diga “não medido” quando faltar braço ou suíte")
        absences.append("pack Core tipado Arena ainda §5 — este é presentation-only")
        return (facts, absences, anchors)
    }

    // MARK: - Facts pack

    @MainActor
    static func facts(
        model: ArenaModel,
        tab: ArenaPremiumTab,
        destination: ArenaPremiumDestination? = nil
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        // WAVE-186: shell pack (tela/aba · cobertura · engine anchor).
        let engineLabel = model.arenaPrimaryEngine.map { ArenaDisplay.engine($0.engine) }
        let shell = packShellFacts(
            tab: tab,
            destination: destination,
            coverageText: model.arenaCoverageText,
            primaryEngineLabel: engineLabel
        )
        facts.append(contentsOf: shell.facts)
        absences.append(contentsOf: shell.absences)
        anchors.append(contentsOf: shell.anchors)

        let liveRuns = model.liveRuns?.runs ?? []
        let primary = model.arenaPrimaryRun
        let focusTab = destination == nil ? tab : tabForDestination(destination!)

        appendLiveControlOrgans(
            model: model,
            destination: destination,
            tab: tab,
            liveRuns: liveRuns,
            primary: primary,
            into: &facts,
            absences: &absences
        )
        appendScoreOrgans(
            model: model,
            destination: destination,
            tab: tab,
            focusTab: focusTab,
            liveRuns: liveRuns,
            into: &facts,
            absences: &absences
        )

        let canDo = occasionCanDo(
            tab: tab,
            destination: destination,
            primary: primary
        )
        if !ArenaLiveControlJudgment.canStop(primary: primary) {
            absences.append("parada indisponível — sem primary stoppable / measurementId")
        }

        return AgenticOccasionPack(
            surface: "arena",
            subject: destination.map { "Arena · \(destinationLabel($0))" } ?? "Arena · \(tab.rawValue)",
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: canDo
        ).render()
    }

    /// WAVE-083: can_do from live face — never always ctaOnlyRunStop.
    // MARK: - Can-do / destinations

    static func occasionCanDo(
        tab: ArenaPremiumTab,
        destination: ArenaPremiumDestination?,
        primary: AtlasArenaLiveRun?
    ) -> AgenticOccasionPack.CanDo {
        if ArenaLiveControlJudgment.canStop(primary: primary) {
            return .ctaOnlyRunStop
        }
        // Browse / results / fleet / capabilities — read only.
        if let destination {
            switch destination {
            case .execution, .queue, .alerts, .plan:
                return .readChat
            case .results:
                return .readChat
            }
        }
        switch tab {
        case .now:
            // Idle/terminal now: chat read; start remains CTA on face (not NL write).
            return .faceCTALocal
        case .fleet, .capabilities, .results:
            return .readChat
        }
    }

    static func destinationLabel(_ d: ArenaPremiumDestination) -> String {
        switch d {
        case .execution: "Execução"
        case .plan: "Plano"
        case .queue: "Fila"
        case .alerts: "Alertas"
        case .results: "Motor"
        }
    }

    /// Tab canônica para um destino (nunca forçar Agora na cara do pack de destinos).
    static func tabForDestination(_ d: ArenaPremiumDestination) -> ArenaPremiumTab {
        switch d {
        case .execution, .queue, .plan, .alerts: .now
        case .results: .results
        }
    }
}
extension ArenaPremiumAskContext {
    @MainActor
    // MARK: - Now · live · pipeline · stop · start · plan
    static func appendLiveControlOrgans(
        model: ArenaModel,
        destination: ArenaPremiumDestination?,
        tab: ArenaPremiumTab,
        liveRuns: [AtlasArenaLiveRun],
        primary: AtlasArenaLiveRun?,
        into facts: inout [String],
        absences: inout [String]
    ) {
        let livePhase = model.livePresentation?.phase
        let nowPack = ArenaNowJudgment.packFacts(
            loadPhase: model.phase,
            livePhase: livePhase,
            compositeNil: model.composite == nil,
            engineTitle: model.arenaLiveEngineTitle
        )
        facts.append(contentsOf: nowPack.facts)
        absences.append(contentsOf: nowPack.absences)

        let livePack = ArenaLiveControlJudgment.packFacts(runs: liveRuns, primary: primary)
        facts.append(contentsOf: livePack.facts)
        absences.append(contentsOf: livePack.absences)

        if let primary {
            let statusPack = ArenaRunStatusJudgment.packFacts(for: primary.status)
            facts.append(contentsOf: statusPack.facts)
            absences.append(contentsOf: statusPack.absences)
        }

        // WAVE-187: measurement presentation (progress · primary · alerts · narrative · list).
        let includeLiveList = destination == .execution || destination == .queue
        let measurement = ArenaLiveControlJudgment.packMeasurementFacts(
            progress: model.livePresentation?.progress,
            primary: primary,
            alertSuiteCount: model.arenaAlertSuiteCount,
            narrative: model.report?.narrative,
            liveRuns: liveRuns,
            includeLiveList: includeLiveList
        )
        facts.append(contentsOf: measurement.facts)
        absences.append(contentsOf: measurement.absences)

        if destination == .execution || (destination == nil && tab == .now && !liveRuns.isEmpty) {
            let planArms = model.activePlan?.arms ?? []
            let projection = ArenaPipelineJudgment.project(
                runs: model.arenaPrimaryMeasurementRuns,
                expectsBare: planArms.contains(.baseline) || model.arenaPrimaryMeasurementRuns.contains { $0.arm == .baseline },
                expectsAtlas: planArms.contains(.withAtlas) || model.arenaPrimaryMeasurementRuns.contains { $0.arm == .withAtlas },
                hasReport: model.report != nil
            )
            let pipePack = ArenaPipelineJudgment.packFacts(projection)
            facts.append(contentsOf: pipePack.facts)
            absences.append(contentsOf: pipePack.absences)
        }

        if ArenaLiveControlJudgment.canStop(primary: primary) {
            let hasReceipt = model.lastStopReceipt?.measurementIdPublic == primary?.measurementIdPublic
            let stopPack = ArenaStopJudgment.packFacts(
                actor: "",
                reason: "",
                hasMatchingReceipt: hasReceipt
            )
            facts.append(contentsOf: stopPack.facts)
            absences.append(contentsOf: stopPack.absences)
            absences.append("stop_sheet: face-only — actor/motivo só no modal de parada")
        }

        let enginesPublished = model.engineCatalog?.engines.count
            ?? model.composite?.engines.count
            ?? 0
        let suitesPublished = model.activePlan?.suites.count
            ?? model.livePresentation?.queuedRuns.count
            ?? 0
        if model.lastStartReceipt != nil
            || destination == .execution
            || destination == .plan
            || (destination == nil && tab == .now)
        {
            let startPack = ArenaStartJudgment.packFacts(
                input: nil,
                receipt: model.lastStartReceipt,
                enginesPublished: enginesPublished,
                suitesPublished: suitesPublished
            )
            facts.append(contentsOf: startPack.facts)
            absences.append(contentsOf: startPack.absences)
        }

        if destination == .plan {
            let planPack = ArenaPlanQueueJudgment.planPackFacts(
                activePlan: model.activePlan,
                measurementRuns: model.arenaPrimaryMeasurementRuns,
                queuedRuns: model.livePresentation?.queuedRuns ?? []
            )
            facts.append(contentsOf: planPack.facts)
            absences.append(contentsOf: planPack.absences)
        }
        if destination == .queue {
            let queuePack = ArenaPlanQueueJudgment.queuePackFacts(
                queuedRuns: model.livePresentation?.queuedRuns ?? []
            )
            facts.append(contentsOf: queuePack.facts)
            absences.append(contentsOf: queuePack.absences)
        }
    }
}
extension ArenaPremiumAskContext {
    @MainActor
    // MARK: - Fleet · capabilities · run sheet · suites
    static func appendScoreOrgans(
        model: ArenaModel,
        destination: ArenaPremiumDestination?,
        tab: ArenaPremiumTab,
        focusTab: ArenaPremiumTab,
        liveRuns: [AtlasArenaLiveRun],
        into facts: inout [String],
        absences: inout [String]
    ) {
        if focusTab == .fleet || destination == nil && tab == .fleet {
            let fleetPack = ArenaFleetJudgment.packFacts(engines: model.composite?.engines ?? [])
            facts.append(contentsOf: fleetPack.facts)
            absences.append(contentsOf: fleetPack.absences)
        }
        if focusTab == .capabilities || destination == nil && tab == .capabilities {
            let caps = model.selectedCapabilities?.capabilities ?? []
            let capPack = ArenaCapabilitiesJudgment.packFacts(caps)
            facts.append(contentsOf: capPack.facts)
            absences.append(contentsOf: capPack.absences)
        }

        let enginesPublished = model.engineCatalog?.engines.count
            ?? model.composite?.engines.count
            ?? 0
        let suitesPublished = model.activePlan?.suites.count
            ?? model.livePresentation?.queuedRuns.count
            ?? 0

        let runSheetPack = ArenaRunSheetJudgment.packFacts(
            engineCount: enginesPublished,
            suiteCount: suitesPublished
        )
        facts.append(contentsOf: runSheetPack.facts)
        absences.append(contentsOf: runSheetPack.absences)

        // WAVE-181: primary engine score judgment (never invent 0 / incomplete Δ).
        let suites = model.scoreboard?.suites ?? []
        let regressionCount = suites.filter(\.hasRegression).count
        let scorePack = ArenaScoreJudgment.packFacts(
            engine: model.arenaPrimaryEngine,
            claimAllowed: model.report?.claimAllowed,
            regressionCount: regressionCount,
            attentionCount: 0
        )
        facts.append(contentsOf: scorePack.facts)
        absences.append(contentsOf: scorePack.absences)

        if focusTab == .results || destination == .results || destination == .alerts
            || (destination == nil && tab == .now)
        {
            let suites = model.scoreboard?.suites ?? []
            if suites.isEmpty {
                absences.append("scoreboard sem suites publicadas neste recorte")
            } else {
                let ranked = suites.enumerated().sorted { lhs, rhs in
                    let l = lhs.element.hasRegression
                    let r = rhs.element.hasRegression
                    if l != r { return l && !r }
                    return lhs.offset < rhs.offset
                }.map(\.element)
                for suite in ranked.prefix(4) {
                    let suitePack = ArenaSuiteJudgment.packFacts(for: suite)
                    facts.append(contentsOf: suitePack.facts)
                    absences.append(contentsOf: suitePack.absences)
                }
            }
        }
    }
}

// MARK: - ArenaModel

// WAVE-138 ArenaModel host state

@MainActor
@Observable
final class ArenaModel {
    let client: AtlasClient

    var phase: LoadPhase = .idle
    var composite: AtlasArenaComposite?
    var scoreboard: AtlasArenaScoreboard?
    var report: AtlasArenaReport?
    var capabilities: AtlasArenaCapabilities?
    var capabilitiesByEngine: [String: AtlasArenaCapabilities] = [:]
    var capabilitiesEngineSelection: String?
    var liveRuns: AtlasArenaLiveRuns?
    var engineCatalog: AtlasArenaEngines?
    var lastStartReceipt: AtlasArenaStartReceipt?
    var lastStopReceipt: AtlasArenaStopReceipt?
    var activePlan: AtlasArenaMeasurementPlan?
    var lastStartReceipts: [AtlasArenaStartReceipt] = []
    var isStartingRuns = false
    var isStoppingMeasurement = false
    var lastStartEnginesCount = 0
    var lastStartRunsPlannedTotal = 0
    var controlError: String?
    private(set) var loadFailureKind: AtlasNetworkFailureKind?
    private(set) var isDomainUnavailable = false
    private(set) var lastLoadedAt: Date?

    func markLoaded() { lastLoadedAt = Date() }
    var visible = false
    var livePollingTask: Task<Void, Never>?
#if DEBUG
    var visualScenarioInstalled = false
#endif

    static let domainUnavailableCopy = "medição ainda não publicada pelo servidor"

    init(client: AtlasClient) {
        self.client = client
    }

    var capabilityEngineOptions: [String] {
        (composite?.engines.map(\.engine) ?? []).filter { capabilitiesByEngine[$0] != nil }
    }

    var selectedCapabilities: AtlasArenaCapabilities? {
        if let selection = capabilitiesEngineSelection, let chosen = capabilitiesByEngine[selection] {
            return chosen
        }
        return capabilityEngineOptions.first.flatMap { capabilitiesByEngine[$0] } ?? capabilities
    }

    func loadCapabilities(
        for composite: AtlasArenaComposite,
        preserveCurrentOnTotalFailure: Bool = false
    ) async {
        var byEngine: [String: AtlasArenaCapabilities] = [:]
        var successfulFetches = 0
        let engines = composite.engines.map(\.engine)
        let client = client
        await withTaskGroup(of: (String, AtlasArenaCapabilities?, Bool).self) { group in
            for engine in engines {
                group.addTask {
                    do {
                        return (engine, try await client.getArenaCapabilities(engine: engine), true)
                    } catch {
                        return (engine, nil, false)
                    }
                }
            }
            for await (engine, profile, succeeded) in group {
                if succeeded { successfulFetches += 1 }
                if let profile, !profile.capabilities.isEmpty {
                    byEngine[engine] = profile
                }
            }
        }
        var aggregateCapabilities: AtlasArenaCapabilities?
        if byEngine.isEmpty {
            if let aggregate = try? await client.getArenaCapabilities(engine: "") {
                successfulFetches += 1
                aggregateCapabilities = aggregate.capabilities.isEmpty ? nil : aggregate
            }
        } else {
            aggregateCapabilities = composite.engines.first.flatMap { byEngine[$0.engine] }
        }
        guard !preserveCurrentOnTotalFailure || successfulFetches > 0 else { return }
        if capabilitiesByEngine != byEngine {
            capabilitiesByEngine = byEngine
        }
        if capabilities != aggregateCapabilities {
            capabilities = aggregateCapabilities
        }
    }

    func publishLiveRuns(_ next: AtlasArenaLiveRuns?) {
        guard let next, liveRuns?.runs != next.runs else { return }
        liveRuns = next
    }

    var preferredEngine: String? {
        composite?.engines.first?.engine
            ?? scoreboard?.suites.lazy.flatMap(\.engines).first?.engine
    }

    var livePresentation: AtlasArenaLivePresentation? {
        liveRuns?.presentation
    }

    var regressionException: String? {
        for suite in scoreboard?.suites ?? [] {
            guard let engine = suite.engines.first(where: \.regressed),
                  let delta = engine.delta else { continue }
            return "regrediu \(ArenaFormat.signed(delta)) · \(ArenaDisplay.suite(suite.suite)) · \(ArenaDisplay.engine(engine.engine))"
        }
        return nil
    }

    var snapshotAgeText: String? {
        guard let lastLoadedAt else { return nil }
        let seconds = max(0, Int(Date().timeIntervalSince(lastLoadedAt)))
        switch seconds {
        case ..<60: return "agora"
        case ..<3600: return "há \(seconds / 60)min"
        default: return "há \(seconds / 3600)h"
        }
    }

    func load() async {
#if DEBUG
        if visualScenarioInstalled { return }
#endif
        phase = .loading
        controlError = nil
        loadFailureKind = nil
        isDomainUnavailable = false
        do {
            async let compositeRequest = client.getArenaComposite()
            async let scoreboardRequest = client.getArenaScoreboard()
            let (nextComposite, nextScoreboard) = try await (compositeRequest, scoreboardRequest)
            async let reportRequest: AtlasArenaReport? = try? client.getArenaReport()
            async let liveRunsRequest: AtlasArenaLiveRuns? = try? client.getArenaLiveRuns()
            async let engineCatalogRequest: AtlasArenaEngines? = try? client.getArenaEngines()
            await loadCapabilities(for: nextComposite)
            composite = nextComposite
            scoreboard = nextScoreboard
            report = await reportRequest
            publishLiveRuns(await liveRunsRequest)
            engineCatalog = await engineCatalogRequest
            lastLoadedAt = Date()
            phase = .loaded
            updateLivePolling()
        } catch {
            let domainMissing = Self.isDomainUnavailableError(error)
            isDomainUnavailable = domainMissing
            loadFailureKind = domainMissing ? nil : atlasNetworkFailureKind(for: error)
            phase = .failed(Self.publicMessage(error))
        }
    }

    func setVisible(_ isVisible: Bool) {
        visible = isVisible
        updateLivePolling()
    }
}

// MARK: - ArenaModelActions

// WAVE-138 ArenaModel actions peel

// MARK: - Host

extension ArenaModel {
    func refreshSummaryKeepingSnapshot(quiet: Bool = false) async {
        if !quiet { controlError = nil }
        do {
            async let compositeRequest = client.getArenaComposite()
            async let scoreboardRequest = client.getArenaScoreboard()
            let (nextComposite, nextScoreboard) = try await (compositeRequest, scoreboardRequest)
            async let reportRequest: AtlasArenaReport? = try? client.getArenaReport()
            async let liveRunsRequest: AtlasArenaLiveRuns? = try? client.getArenaLiveRuns()
            await loadCapabilities(for: nextComposite, preserveCurrentOnTotalFailure: true)
            composite = nextComposite
            scoreboard = nextScoreboard
            report = await reportRequest ?? report
            publishLiveRuns(await liveRunsRequest)
            markLoaded()
            if case .idle = phase { phase = .loaded }
            updateLivePolling()
        } catch {
            if !quiet { controlError = Self.publicMessage(error) }
        }
    }

    func refreshCapabilities() async {
        guard let composite else { return }
        await loadCapabilities(for: composite, preserveCurrentOnTotalFailure: true)
    }

    func refreshLiveRuns() async {
        publishLiveRuns(try? await client.getArenaLiveRuns())
        updateLivePolling()
    }

    func startRuns(inputs: [AtlasArenaStartInput]) async {
        guard !isStartingRuns else { return }
        controlError = nil
        guard let plan = AtlasArenaMeasurementPlan(inputs: inputs) else {
            controlError = "selecione suítes, motores e braços; informe ator e motivo"
            return
        }
        isStartingRuns = true
        defer { isStartingRuns = false }
        activePlan = plan
        lastStartReceipt = nil
        lastStartReceipts = []
        lastStartEnginesCount = 0
        lastStartRunsPlannedTotal = 0
        do {
            for input in inputs {
                let receipt = try await client.startArenaRuns(input: input)
                lastStartReceipt = receipt
                lastStartReceipts.append(receipt)
                lastStartEnginesCount = lastStartReceipts.count
                lastStartRunsPlannedTotal += receipt.runsPlanned
            }
            await refreshLiveRuns()
        } catch {
            if lastStartReceipts.isEmpty {
                controlError = Self.publicMessage(error)
            } else {
                controlError = "\(lastStartReceipts.count) de \(inputs.count) motores enfileirados · o restante não foi confirmado"
                await refreshLiveRuns()
            }
        }
    }

    func stopMeasurement(
        measurementId: String,
        operatorActor: String,
        operatorReason: String
    ) async {
        guard !isStoppingMeasurement else { return }
        let input = AtlasArenaStopInput(
            operatorActor: operatorActor,
            operatorReason: operatorReason
        )
        guard input.isLocallyValidForSubmission else {
            controlError = "informe operador e motivo para parar a medição"
            return
        }
        isStoppingMeasurement = true
        controlError = nil
        defer { isStoppingMeasurement = false }
        do {
            lastStopReceipt = try await client.stopArenaMeasurement(
                measurementId: measurementId,
                input: input
            )
            await refreshLiveRuns()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}

extension ArenaModel {
    var regressionSummary: String? {
        let n = scoreboard?.suites.filter { suite in
            suite.engines.contains(where: \.regressed)
        }.count ?? 0
        guard n > 0 else { return nil }
        return n == 1 ? "1 regressão" : "\(n) regressões"
    }
}

// MARK: - Helpers

extension ArenaModel {
    var shouldPollLiveRuns: Bool {
#if DEBUG
        if visualScenarioInstalled { return false }
#endif
        return visible
    }

    func updateLivePolling() {
        guard shouldPollLiveRuns else {
            livePollingTask?.cancel()
            livePollingTask = nil
            return
        }
        guard livePollingTask == nil else { return }
        livePollingTask = Task { @MainActor [weak self] in
            var lastFullRefresh = ContinuousClock.now
            while let self, !Task.isCancelled, self.shouldPollLiveRuns {
                try? await Task.sleep(for: .seconds(10))
                guard !Task.isCancelled, self.shouldPollLiveRuns else { break }
                let runsBefore = self.liveRuns?.runs
                await self.refreshLiveRuns()
                let transitioned = runsBefore != self.liveRuns?.runs
                if transitioned || ContinuousClock.now - lastFullRefresh > .seconds(30) {
                    lastFullRefresh = ContinuousClock.now
                    await self.refreshSummaryKeepingSnapshot(quiet: true)
                }
            }
        }
    }

    static func publicMessage(_ error: Error) -> String {
        if isDomainUnavailableError(error) {
            return domainUnavailableCopy
        }
        if let api = error as? AtlasApiError { return api.message }
        return "não foi possível carregar a Arena"
    }

    static func isDomainUnavailableError(_ error: Error) -> Bool {
        (error as? AtlasApiError)?.status == 404
    }
}

#if DEBUG

extension ArenaModel {
    @discardableResult
    func installVisualScenarioIfRequested(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> Bool {
        guard !visualScenarioInstalled,
              let raw = arguments.value(after: "-atlas.arena.scenario") else {
            return visualScenarioInstalled
        }

        do {
            let snapshot = try AtlasArenaVisualFixture.snapshot(scenario: raw)
            composite = snapshot.composite
            scoreboard = snapshot.scoreboard
            report = snapshot.report
            capabilities = snapshot.capabilities
            capabilitiesByEngine = ["verboo_kimi_k2_7": snapshot.capabilities]
            capabilitiesEngineSelection = "verboo_kimi_k2_7"
            engineCatalog = snapshot.engineCatalog
            liveRuns = snapshot.liveRuns
            activePlan = snapshot.plan
            phase = .loaded
            visualScenarioInstalled = true
            markLoaded()
            return true
        } catch {
            assertionFailure("Arena visual fixture inválida: \(error)")
            return false
        }
    }
}

private extension Array where Element == String {
    func value(after flag: String) -> String? {
        guard let index = firstIndex(of: flag), indices.contains(index + 1) else { return nil }
        return self[index + 1]
    }
}
#endif
