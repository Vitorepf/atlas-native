import SwiftUI
import AtlasCore

struct ArenaPremiumPlanView: View {
    @Bindable var model: ArenaModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(text: "Ordem de medição", tone: .active)
                .accessibilityIdentifier(A11yID.arenaPremiumPlan)
            Text("Plano")
                .font(AtlasFont.serif(36))
                .foregroundStyle(AtlasTheme.textPrimary)
            if let plan = model.activePlan {
                headline(plan)
                sequence(plan)
            } else {
                empty
            }
        }
    }

    private func headline(_ plan: AtlasArenaMeasurementPlan) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 28) {
                metric(plan.engines.count, "motores")
                metric(plan.suites.count, "suítes")
                metric(plan.arms.count, "braços")
                metric(plan.runsPlanned, "corridas")
            }
            VStack(alignment: .leading, spacing: 12) {
                metric(plan.engines.count, "motores")
                metric(plan.suites.count, "suítes")
                metric(plan.runsPlanned, "corridas")
            }
        }
    }

    private func sequence(_ plan: AtlasArenaMeasurementPlan) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ArenaPremiumHairline()
            ForEach(Array(plan.suites.enumerated()), id: \.element) { index, suite in
                HStack(spacing: 14) {
                    Text(String(format: "%02d", index + 1))
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .frame(width: 28, alignment: .leading)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(ArenaDisplay.suite(suite))
                            .font(AtlasFont.serif(17))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(plan.arms.map(\.labelPT).joined(separator: " → "))
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
            Text("A seleção enviada pode avançar; casos concluídos não são reabertos.")
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
            Text("Crie uma medição para organizar suítes, motores e braços.")
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
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
            ArenaPremiumKicker(text: "Aguardando execução", tone: queued.isEmpty ? .neutral : .active)
                .accessibilityIdentifier(A11yID.arenaPremiumQueue)
            HStack(alignment: .lastTextBaseline) {
                Text("\(queuedSuites.count)")
                    .font(AtlasFont.serif(58))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(queuedSuites.count == 1 ? "suíte na fila" : "suítes na fila")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            queueRows
            Text("Fila significa programado, não iniciado. Nenhuma porcentagem é mostrada antes do primeiro caso.")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
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
                            .font(AtlasFont.serif(17))
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
        let arms = runs.compactMap(\.arm).map(\.labelPT)
        let engine = runs.first.map { ArenaDisplay.engine($0.engineDisplayName) }
        return ([engine] + arms).compactMap(\.self).joined(separator: " · ")
    }
}
