import SwiftUI
import AtlasCore

/// Execução = o ÚNICO mapa da medição (mockup operador 2026-07-20).
/// Pipeline macro + casos da suíte ao vivo + corridas tocáveis.
struct ArenaPremiumExecutionView: View {
    @Bindable var model: ArenaModel
    let onStop: (AtlasArenaLiveRun) -> Void

    private var runs: [AtlasArenaLiveRun] { model.arenaPrimaryMeasurementRuns }
    private var primary: AtlasArenaLiveRun? { model.arenaPrimaryRun }

    private var orderedRuns: [AtlasArenaLiveRun] {
        let live = runs.filter { $0.status == .running || $0.status == .stopping }
        let done = runs.filter {
            $0.status == .completed || $0.status == .failed || $0.status == .stopped
        }
        let upcoming = runs.filter { $0.status == .queued }
        return live + done + upcoming
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
        guard let primary else { return false }
        return primary.canStop == true && primary.measurementIdPublic != nil
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
                .accessibilityAddTraits(.isHeader)
            Text("Ordem, estado e progresso confirmados pelo servidor.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(statusLabel), \(model.arenaLiveEngineTitle)")
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
                    .accessibilityLabel("Casos ainda sem denominador nesta corrida.")
            }
        } else if runs.isEmpty {
            Text("Nenhuma corrida nesta medição.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityLabel("Nenhuma corrida nesta medição.")
                .accessibilityIdentifier(A11yID.arenaPremiumState("execution-empty"))
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
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("Corridas")
                .padding(.bottom, 10)
            if orderedRuns.isEmpty {
                Text("Ainda sem corridas publicadas.")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityLabel("Ainda sem corridas publicadas.")
            } else {
                ForEach(orderedRuns) { run in
                    NavigationLink {
                        ArenaPremiumRunDetailView(run: run)
                    } label: {
                        runRow(run)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(.isButton)
                    ArenaPremiumHairline()
                }
            }
        }
    }

    private func runRow(_ run: AtlasArenaLiveRun) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            Text(rowGlyph(run))
                .font(AtlasFont.serif(14))
                .foregroundStyle(tone(run.status).color)
                .frame(width: 22, alignment: .center)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(ArenaDisplay.suite(run.suite))
                    .atlasSans(16, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(rowDetail(run))
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            Spacer(minLength: 8)
            Text(rowTrailing(run))
                .font(AtlasFont.mono(11, .medium))
                .foregroundStyle(tone(run.status).color)
                .multilineTextAlignment(.trailing)
            ArenaPremiumChevron()
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .accessibilityIdentifier(A11yID.arenaPremiumExecutionRun(run.runIdPublic))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(ArenaDisplay.suite(run.suite)), \(run.arm?.labelPT ?? ""), \(rowTrailing(run))"
        )
        .accessibilityHint("Abre os casos desta corrida")
    }

    /// Ao vivo = ▸ (rodando). Nunca ✦ do Atlas nas corridas.
    private func rowGlyph(_ run: AtlasArenaLiveRun) -> String {
        switch run.status {
        case .running, .stopping: "▸"
        case .completed: "✓"
        case .failed: "※"
        case .queued: "◷"
        case .stopped, .unknown: "·"
        }
    }

    private func rowDetail(_ run: AtlasArenaLiveRun) -> String {
        if let done = run.casesDone, let total = run.casesTotal, total > 0 {
            return "\(done)/\(total) casos"
        }
        return run.arm?.labelPT ?? run.status.displayPT
    }

    private func rowTrailing(_ run: AtlasArenaLiveRun) -> String {
        let arm = run.arm?.labelPT
        let state: String = switch run.status {
        case .running: "ao vivo"
        case .stopping: "parando"
        case .queued: "na fila"
        case .completed: "concluída"
        case .failed: "falhou"
        case .stopped: "parada"
        case .unknown: run.status.displayPT
        }
        return [state, arm].compactMap(\.self).joined(separator: " · ")
    }

    private var statusLabel: String {
        switch model.livePresentation?.phase ?? .idle {
        case .idle: "Sem execução"
        case .queued: "Na fila"
        case .running: "Ao vivo"
        case .stopping: "Parando"
        case .stopped: "Parada"
        case .completed: "Concluída"
        case .failed: "Interrompida"
        }
    }

    private var statusTone: ArenaPremiumTone {
        switch model.livePresentation?.phase ?? .idle {
        case .running, .queued, .stopping: .active
        case .completed: .positive
        case .failed: .negative
        case .idle, .stopped: .neutral
        }
    }

    private func tone(_ status: AtlasArenaRunStatus) -> ArenaPremiumTone {
        switch status {
        case .queued, .running, .stopping: .active
        case .completed: .positive
        case .failed: .negative
        case .stopped, .unknown: .neutral
        }
    }
}


/// Detalhe de uma corrida: progresso + casos (lista real = §5 Core).
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
                .accessibilityAddTraits(.isHeader)
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
        let remaining = max(0, total - done)
        switch run.status {
        case .running, .stopping:
            return "\(done) confirmados · 1 em andamento · \(max(0, remaining - 1)) a seguir"
        case .queued:
            return "\(total) na fila · ainda não iniciado"
        case .completed:
            return "\(done) de \(total) concluídos"
        case .failed:
            return "\(done) de \(total) antes da falha"
        case .stopped:
            return "\(done) de \(total) quando parou"
        case .unknown:
            return "\(done) de \(total)"
        }
    }

    private var statusLabel: String {
        switch run.status {
        case .running: "Ao vivo"
        case .stopping: "Parando"
        case .queued: "Na fila"
        case .completed: "Concluída"
        case .failed: "Falhou"
        case .stopped: "Parada"
        case .unknown: "Estado"
        }
    }

    private var statusTone: ArenaPremiumTone {
        switch run.status {
        case .running, .stopping, .queued: .active
        case .completed: .positive
        case .failed: .negative
        case .stopped, .unknown: .neutral
        }
    }
}


/// Fase macro da medição — presentation-only, derivada dos runs vivos.
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

    static func project(
        runs: [AtlasArenaLiveRun],
        expectsBare: Bool,
        expectsAtlas: Bool,
        hasReport: Bool
    ) -> ArenaPremiumPipelineProjection {
        var marks: [ArenaPremiumPipelineStep: ArenaPremiumPipelineMark] = [:]
        let bare = runs.filter { $0.arm == .baseline }
        let atlas = runs.filter { $0.arm == .withAtlas }
        let anyLive = runs.contains { $0.status == .running || $0.status == .stopping }
        let allQueued = !runs.isEmpty && runs.allSatisfy { $0.status == .queued }
        let allTerminal = !runs.isEmpty && runs.allSatisfy(Self.isTerminal)

        if runs.isEmpty {
            marks[.prepare] = .pending
        } else if allQueued {
            marks[.prepare] = .live
        } else {
            marks[.prepare] = .done
        }

        marks[.bare] = armMark(
            bare,
            expected: expectsBare || !bare.isEmpty,
            prepareDone: marks[.prepare] == .done
        )
        marks[.withAtlas] = armMark(
            atlas,
            expected: expectsAtlas || !atlas.isEmpty,
            prepareDone: marks[.prepare] == .done
        )

        if allTerminal {
            marks[.consolidate] = hasReport ? .done : .live
        } else if anyLive || allQueued {
            marks[.consolidate] = .pending
        } else {
            marks[.consolidate] = .pending
        }

        return ArenaPremiumPipelineProjection(marks: marks)
    }

    private static func armMark(
        _ armRuns: [AtlasArenaLiveRun],
        expected: Bool,
        prepareDone: Bool
    ) -> ArenaPremiumPipelineMark {
        guard expected else { return prepareDone ? .done : .pending }
        if armRuns.contains(where: { $0.status == .running || $0.status == .stopping }) {
            return .live
        }
        if !armRuns.isEmpty, armRuns.allSatisfy(isTerminal) {
            return .done
        }
        return .pending
    }

    private static func isTerminal(_ run: AtlasArenaLiveRun) -> Bool {
        switch run.status {
        case .completed, .failed, .stopped: true
        default: false
        }
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
        .accessibilityLabel(spoken)
        .accessibilityIdentifier(A11yID.arenaPremiumExecutionPipeline)
    }

    private func stepColumn(_ step: ArenaPremiumPipelineStep) -> some View {
        let mark = projection.marks[step] ?? .pending
        return VStack(spacing: 8) {
            Text(glyph(step, mark))
                .font(AtlasFont.serif(14))
                .foregroundStyle(color(mark))
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

    /// Corrida ao vivo usa ▸; ✦ só na fase cujo nome é Atlas.
    private func glyph(_ step: ArenaPremiumPipelineStep, _ mark: ArenaPremiumPipelineMark) -> String {
        switch mark {
        case .done: "✓"
        case .pending: "○"
        case .live:
            step == .withAtlas ? "✦" : "▸"
        }
    }

    private func color(_ mark: ArenaPremiumPipelineMark) -> Color {
        switch mark {
        case .live: AtlasTheme.accent
        case .done: AtlasTheme.textPrimary
        case .pending: AtlasTheme.textTertiary
        }
    }

    private var spoken: String {
        ArenaPremiumPipelineStep.allCases.map { step in
            let mark = projection.marks[step] ?? .pending
            let state: String = switch mark {
            case .done: "feito"
            case .live: "ao vivo"
            case .pending: "pendente"
            }
            return "\(step.title) \(state)"
        }.joined(separator: ", ")
    }
}
