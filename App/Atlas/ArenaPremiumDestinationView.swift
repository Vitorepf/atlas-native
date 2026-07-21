import SwiftUI
import AtlasCore

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
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg.opacity(0.92), AtlasTheme.bg],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 28)
                .allowsHitTesting(false)
                AgenticPill(
                    invite: ArenaPremiumAskContext.invite(tab: .now, destination: target),
                    accessibilityId: A11yID.arenaPremiumAskPill
                ) {
                    askDraft = ""
                    showingAsk = true
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $showingAsk) {
            ConversationView(
                client: session.client,
                threadId: askThreadId,
                title: "Arena · \(title)",
                emptyPrompt: ArenaPremiumAskContext.invite(tab: .now, destination: target),
                emptySuggestions: ArenaPremiumAskContext.emptySuggestions(tab: .now, destination: target),
                taskKind: "arena",
                workspace: nil,
                draft: askDraft,
                turnFacts: { [model, target] _ in
                    ArenaPremiumAskContext.facts(model: model, tab: .now, destination: target)
                },
                onThread: { askThreadId = $0 },
                hidesNavigationBack: true
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(AtlasTheme.bg)
            .presentationCornerRadius(28)
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


struct ArenaPremiumPlanView: View {
    @Bindable var model: ArenaModel

    private var liveRuns: [AtlasArenaLiveRun] {
        // União medição + fila (dedup por suíte+braço): o Plano nunca fica
        // mais magro que a Fila, mesmo se o measurementId não casar em toda
        // corrida enfileirada. Corridas vivas primeiro, fila depois.
        var seen = Set<String>()
        return (model.arenaPrimaryMeasurementRuns + (model.livePresentation?.queuedRuns ?? []))
            .compactMap { run in
                seen.insert("\(run.suite)|\(run.arm?.rawValue ?? "")").inserted ? run : nil
            }
    }

    private var liveSuites: [String] {
        var seen = Set<String>()
        return liveRuns.compactMap { seen.insert($0.suite).inserted ? $0.suite : nil }
    }

    private var liveArmsText: String {
        var seen = Set<String>()
        return liveRuns.compactMap(\.arm)
            .compactMap { seen.insert($0.rawValue).inserted ? $0.labelPT : nil }
            .joined(separator: " → ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(text: "Ordem de medição")
                .accessibilityIdentifier(A11yID.arenaPremiumPlan)
            Text("Plano")
                .font(AtlasFont.serif(36))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let plan = model.activePlan {
                headline(engines: plan.engines.count, suites: plan.suites.count,
                         arms: plan.arms.count, runs: plan.runsPlanned)
                suiteSequence(plan.suites,
                              armsText: plan.arms.map(\.labelPT).joined(separator: " → "),
                              footer: "A seleção enviada pode avançar; casos concluídos não são reabertos.")
            } else if !liveSuites.isEmpty {
                // Medição viva sem plano explícito (veio do servidor): a
                // medição É o plano — derivar das corridas reais. Dizer
                // "nenhum plano" com suítes na fila era a contradição.
                headline(engines: Set(liveRuns.map(\.engineDisplayName)).count,
                         suites: liveSuites.count,
                         arms: Set(liveRuns.compactMap { $0.arm?.rawValue }).count,
                         runs: liveRuns.count)
                suiteSequence(liveSuites,
                              armsText: liveArmsText,
                              footer: "Ordem derivada da medição em curso; casos concluídos não são reabertos.")
            } else {
                empty
            }
        }
    }

    private func headline(engines: Int, suites: Int, arms: Int, runs: Int) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 28) {
                metric(engines, "motores")
                metric(suites, "suítes")
                metric(arms, "braços")
                metric(runs, "corridas")
            }
            VStack(alignment: .leading, spacing: 12) {
                metric(engines, "motores")
                metric(suites, "suítes")
                metric(runs, "corridas")
            }
        }
    }

    private func suiteSequence(_ suites: [String], armsText: String, footer: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ArenaPremiumHairline()
            ForEach(Array(suites.enumerated()), id: \.element) { index, suite in
                HStack(spacing: 14) {
                    Text(String(format: "%02d", index + 1))
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .frame(width: 28, alignment: .leading)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(ArenaDisplay.suite(suite))
                            .atlasSans(16, .medium)
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(armsText)
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                    Spacer()
                    ArenaPremiumIcon(
                        symbol: ArenaPremiumIconography.planStatus(planStatus(suite)),
                        tone: planTone(suite)
                    )
                }
                .padding(.vertical, 14)
                .accessibilityIdentifier(A11yID.arenaPremiumPlanRow(suite))
                ArenaPremiumHairline()
            }
            Text(footer)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 16)
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 16) {
            ArenaPremiumEmptyGlyph(symbol: "list.bullet.rectangle")
            Text("Nenhum plano ativo")
                .font(AtlasFont.serif(29))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Crie uma medição para organizar suítes, motores e braços.")
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Nenhum plano ativo. Crie uma medição para organizar suítes, motores e braços."
        )
        .accessibilityIdentifier(A11yID.arenaPremiumState("plan-empty"))
    }

    private func metric(_ value: Int, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(value)").font(AtlasFont.serif(30)).foregroundStyle(AtlasTheme.textPrimary)
            Text(label).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func planStatus(_ suite: String) -> AtlasArenaRunStatus? {
        let statuses = model.arenaPrimaryMeasurementRuns.filter { $0.suite == suite }.map(\.status)
        if statuses.contains(.running) { return .running }
        if statuses.contains(.stopping) { return .stopping }
        if statuses.contains(.queued) { return .queued }
        if statuses.contains(.failed) { return .failed }
        if !statuses.isEmpty, statuses.allSatisfy({ $0 == .completed }) { return .completed }
        if statuses.contains(.stopped) { return .stopped }
        return nil
    }

    private func planTone(_ suite: String) -> ArenaPremiumTone {
        switch planStatus(suite) {
        case .running, .stopping, .queued: .active
        case .completed: .positive
        case .failed: .negative
        case .stopped, .unknown, nil: .neutral
        }
    }

}

struct ArenaPremiumQueueView: View {
    @Bindable var model: ArenaModel

    private var queued: [AtlasArenaLiveRun] {
        model.livePresentation?.queuedRuns ?? []
    }

    private var queuedSuites: [String] {
        var seen = Set<String>()
        return queued.compactMap { seen.insert($0.suite).inserted ? $0.suite : nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(text: "Aguardando execução", tone: queued.isEmpty ? .neutral : .active, showsLiveMark: !queued.isEmpty)
                .accessibilityIdentifier(A11yID.arenaPremiumQueue)
            HStack(alignment: .lastTextBaseline) {
                Text("\(queuedSuites.count)")
                    .font(AtlasFont.serif(58))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(queuedSuites.count == 1 ? "suíte na fila" : "suítes na fila")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            // Sem rodapé-manual: o kicker "aguardando execução" + o relógio
            // por linha já dizem o estado — meta-copy é ruído.
            queueRows
        }
    }

    private var queueRows: some View {
        VStack(spacing: 0) {
            ArenaPremiumHairline()
            ForEach(Array(queuedSuites.enumerated()), id: \.element) { index, suite in
                HStack(spacing: 14) {
                    Text("\(index + 1)")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .frame(width: 26, alignment: .leading)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ArenaDisplay.suite(suite))
                            .atlasSans(16, .medium)
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(queueDetail(suite))
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                    Spacer()
                    ArenaPremiumIcon(symbol: "clock", tone: .muted)
                }
                .padding(.vertical, 14)
                .accessibilityIdentifier(A11yID.arenaPremiumQueueRow(suite))
                ArenaPremiumHairline()
            }
            if queued.isEmpty {
                Text("Fila vazia")
                    .font(.system(.callout))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
            }
        }
    }

    private func queueDetail(_ suite: String) -> String {
        let runs = queued.filter { $0.suite == suite }
        // Dedup dos braços: 2 motores × 2 braços rendia "sem Atlas · com
        // Atlas · sem Atlas · com Atlas" (a quebra da Fila) — cada braço uma vez.
        var seenArms = Set<String>()
        let arms = runs.compactMap(\.arm)
            .compactMap { seenArms.insert($0.rawValue).inserted ? $0.labelPT : nil }
        let engine = runs.first.map { ArenaDisplay.engine($0.engineDisplayName) }
        return ([engine] + arms).compactMap(\.self).joined(separator: " · ")
    }
}


/// Frota medida — ranking editorial de todos os motores (com vs sem Atlas).
/// Dados: `composite.engines` apenas; ausência = “não medido”, nunca zero.
struct ArenaPremiumFleetView: View {
    @Bindable var model: ArenaModel

    private var engines: [AtlasArenaCompositeEngine] {
        let raw = model.composite?.engines ?? []
        return raw.sorted { lhs, rhs in
            switch (lhs.atlasMultiplier, rhs.atlasMultiplier) {
            case let (l?, r?): return l > r
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil):
                switch (lhs.composite, rhs.composite) {
                case let (l?, r?): return l > r
                case (_?, nil): return true
                case (nil, _?): return false
                default: return lhs.engine < rhs.engine
                }
            }
        }
    }

    private var best: AtlasArenaCompositeEngine? {
        engines.first { $0.atlasMultiplier != nil && ($0.atlasMultiplier ?? 0) > 0 }
            ?? engines.first { $0.composite != nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            header
            if engines.isEmpty {
                empty
            } else {
                ForEach(engines) { engine in
                    fleetRow(engine, highlight: engine.id == best?.id)
                }
            }
        }
        .accessibilityIdentifier(A11yID.arenaPremiumFleet)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: "Frota medida · \(engines.count) \(engines.count == 1 ? "motor" : "motores")"
            )
            Text("Onde o Atlas sobe")
                .font(AtlasFont.serif(31))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let best, let mult = best.atlasMultiplier {
                Text("melhor ganho · \(ArenaDisplay.engine(best.engine)) · \(ArenaFormat.multiplier(mult))")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.accent)
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 14) {
            ArenaPremiumEmptyGlyph(symbol: "gauge.with.dots.needle.33percent")
            Text("Nenhum motor medido")
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Rode uma medição com pelo menos um motor para ver o ranking da frota.")
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Nenhum motor medido. Rode uma medição com pelo menos um motor para ver o ranking da frota.")
        .accessibilityIdentifier(A11yID.arenaPremiumState("fleet-empty"))
    }

    private func fleetRow(_ engine: AtlasArenaCompositeEngine, highlight: Bool) -> some View {
        let without = engine.withoutAtlasComposite
        let withAtlas = engine.withAtlasComposite
        let maxScore = max(without ?? 0, withAtlas ?? 0, 10)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(ArenaDisplay.engine(engine.engine))
                    .atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                multiplierLabel(engine)
            }
            if without != nil || withAtlas != nil {
                bar(label: "sem", value: without, ceiling: maxScore, atlas: false)
                bar(label: "Atlas", value: withAtlas, ceiling: maxScore, atlas: true)
            } else {
                Text("não medido")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            ArenaPremiumHairline()
        }
        .padding(.top, highlight ? 2 : 0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(fleetSpoken(engine))
        .accessibilityIdentifier(A11yID.arenaPremiumFleetRow(engine.engine))
    }

    @ViewBuilder
    private func multiplierLabel(_ engine: AtlasArenaCompositeEngine) -> some View {
        if let mult = engine.atlasMultiplier {
            Text(ArenaFormat.multiplier(mult))
                .font(AtlasFont.mono(11, .medium))
                .foregroundStyle(mult >= 1 ? AtlasTheme.accent : AtlasTheme.alert)
        } else if engine.composite == nil {
            Text("não medido")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    private func bar(label: String, value: Double?, ceiling: Double, atlas: Bool) -> some View {
        let fraction: CGFloat = {
            guard let value, ceiling > 0 else { return 0 }
            return CGFloat(min(Swift.max(value / ceiling, 0), 1))
        }()
        return HStack(spacing: 10) {
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(width: 44, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 2)
                    Capsule()
                        .fill(atlas ? AtlasTheme.accent : AtlasTheme.textSecondary.opacity(0.55))
                        .frame(width: Swift.max(geo.size.width * fraction, value == nil ? 0 : 2), height: 2)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 14)
            Text(ArenaFormat.score(value))
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 36, alignment: .trailing)
        }
        .accessibilityHidden(true)
    }

    private func fleetSpoken(_ engine: AtlasArenaCompositeEngine) -> String {
        let name = ArenaDisplay.engine(engine.engine)
        if let mult = engine.atlasMultiplier {
            return "\(name), multiplicador \(ArenaFormat.multiplier(mult)), sem Atlas \(ArenaFormat.score(engine.withoutAtlasComposite)), com Atlas \(ArenaFormat.score(engine.withAtlasComposite))"
        }
        return "\(name), não medido"
    }
}


struct ArenaPremiumAlertsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: ArenaModel
    let onSuite: (AtlasArenaSuite) -> Void

    private var reportAlertSuites: Set<String> {
        Set(reportAlerts.map(\.suite))
    }

    private var regressions: [AtlasArenaSuite] {
        model.scoreboard?.suites.filter {
            $0.hasRegression && !reportAlertSuites.contains($0.suite)
        } ?? []
    }

    private var reportAlerts: [AtlasArenaReportSuite] {
        model.report?.attentionSuites ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(
                text: hasAlerts ? "Exceções que pedem atenção" : "Sem exceções",
                tone: hasAlerts ? .negative : .positive
            )
            .accessibilityIdentifier(A11yID.arenaPremiumAlerts)
            HStack(alignment: .lastTextBaseline, spacing: 7) {
                Text("\(regressions.count + reportAlerts.count)")
                    .font(AtlasFont.serif(58))
                    .foregroundStyle(hasAlerts ? AtlasTheme.alert : AtlasTheme.textPrimary)
                Text("alertas")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            alertRows
            blockers
        }
    }

    private var alertRows: some View {
        VStack(spacing: 0) {
            ArenaPremiumHairline()
            ForEach(regressions) { suite in
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onSuite(suite)
                } label: {
                    alertRow(
                        title: ArenaDisplay.suite(suite.suite),
                        detail: regressionDetail(suite),
                        symbol: "arrow.down.right"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    "\(ArenaDisplay.suite(suite.suite)), \(regressionDetail(suite))"
                )
                .accessibilityHint("abre a suíte com regressão")
                .accessibilityAddTraits(.isButton)
                ArenaPremiumHairline()
            }
            ForEach(reportAlerts) { report in
                alertRow(
                    title: ArenaDisplay.suite(report.suite),
                    detail: report.status.displayPT,
                    symbol: "exclamationmark.triangle"
                )
                ArenaPremiumHairline()
            }
            if !hasAlerts {
                HStack(spacing: 10) {
                    ArenaPremiumIcon(
                        symbol: ArenaPremiumIconography.coverage,
                        tone: .positive
                    )
                    Text("Nenhuma regressão ou falha publicada")
                }
                    .font(.system(.callout))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Nenhuma regressão ou falha publicada")
                    .accessibilityIdentifier(A11yID.arenaPremiumState("alerts-empty"))
            }
        }
    }

    @ViewBuilder
    private var blockers: some View {
        if let blockers = model.report?.claimBlockers, !blockers.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                ArenaPremiumKicker(text: "Publicação bloqueada")
                ForEach(blockers, id: \.self) { blocker in
                    HStack(spacing: 8) {
                        ArenaPremiumIcon(
                            symbol: ArenaPremiumIconography.blocked,
                            tone: .neutral,
                            role: .compact
                        )
                        Text(publicBlocker(blocker))
                    }
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
            }
        }
    }

    private var hasAlerts: Bool { !regressions.isEmpty || !reportAlerts.isEmpty }

    private func alertRow(title: String, detail: String, symbol: String) -> some View {
        HStack(spacing: 14) {
            ArenaPremiumIcon(symbol: symbol, tone: .negative)
            Text(title)
                .atlasSans(16, .medium)
                .foregroundStyle(AtlasTheme.textPrimary)
            Spacer()
            Text(detail)
                .font(AtlasFont.mono(10, .medium))
                .foregroundStyle(AtlasTheme.alert)
                .multilineTextAlignment(.trailing)
            ArenaPremiumChevron()
        }
        .frame(minHeight: 58)
        .contentShape(Rectangle())
    }

    private func regressionDetail(_ suite: AtlasArenaSuite) -> String {
        let delta = suite.engines.first(where: \.regressed)?.delta
        return "\(ArenaFormat.signed(delta)) · regressão"
    }

    private func publicBlocker(_ raw: String) -> String {
        switch raw {
        case "missing_data": "há dados incompletos"
        case "pipeline_invalid": "a validação do pipeline falhou"
        case "suite_failed": "uma suíte não concluiu"
        default: "resultado ainda não pode ser afirmado"
        }
    }
}
