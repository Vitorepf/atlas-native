import SwiftUI
import AtlasCore

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
