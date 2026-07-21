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
        case .running: return ArenaRunStatusJudgment.label(for: .running)
        case .stopping: return ArenaRunStatusJudgment.label(for: .stopping)
        case .attention: return liveFace.kicker
        case .queued: return ArenaRunStatusJudgment.label(for: .queued)
        case .quietDone:
            switch model.livePresentation?.phase ?? .idle {
            case .completed: return ArenaRunStatusJudgment.label(for: .completed)
            case .stopped: return ArenaRunStatusJudgment.label(for: .stopped)
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
        ArenaRunStatusJudgment.label(for: run.status)
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
