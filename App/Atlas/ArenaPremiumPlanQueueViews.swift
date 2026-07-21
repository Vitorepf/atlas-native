import SwiftUI
import AtlasCore

struct ArenaPremiumPlanView: View {
    @Bindable var model: ArenaModel

    /// WAVE-085: live ∪ queue merge from Judgment.
    private var liveRuns: [AtlasArenaLiveRun] {
        ArenaPlanQueueJudgment.mergedLiveRuns(
            measurementRuns: model.arenaPrimaryMeasurementRuns,
            queuedRuns: model.livePresentation?.queuedRuns ?? []
        )
    }

    private var liveSuites: [String] {
        ArenaPlanQueueJudgment.liveSuites(from: liveRuns)
    }

    private var planFace: ArenaPlanFace {
        ArenaPlanQueueJudgment.planFace(
            activePlan: model.activePlan,
            liveSuites: liveSuites
        )
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
                .accessibilityValue(planFace.productWord)
            switch planFace {
            case .published:
                if let plan = model.activePlan {
                    headline(
                        engines: plan.engines.count,
                        suites: plan.suites.count,
                        arms: plan.arms.count,
                        runs: plan.runsPlanned
                    )
                    suiteSequence(
                        plan.suites,
                        armsText: plan.arms.map(\.labelPT).joined(separator: " → "),
                        footer: planFace.footer
                    )
                }
            case .derivedLive:
                headline(
                    engines: Set(liveRuns.map(\.engineDisplayName)).count,
                    suites: liveSuites.count,
                    arms: Set(liveRuns.compactMap { $0.arm?.rawValue }).count,
                    runs: liveRuns.count
                )
                suiteSequence(
                    liveSuites,
                    armsText: liveArmsText,
                    footer: planFace.footer
                )
            case .empty:
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
                let status = ArenaPlanQueueJudgment.suiteStatus(
                    suite: suite,
                    measurementRuns: model.arenaPrimaryMeasurementRuns
                )
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
                        symbol: ArenaPremiumIconography.planStatus(status),
                        tone: ArenaPlanQueueJudgment.suiteTone(status)
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
            Text(ArenaPlanFace.empty.footer)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityValue(ArenaPlanFace.empty.productWord)
    }

    private func metric(_ value: Int, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(value)").font(AtlasFont.serif(30)).foregroundStyle(AtlasTheme.textPrimary)
            Text(label).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textSecondary)
        }
    }
}

struct ArenaPremiumQueueView: View {
    @Bindable var model: ArenaModel

    private var queued: [AtlasArenaLiveRun] {
        model.livePresentation?.queuedRuns ?? []
    }

    private var queuedSuites: [String] {
        ArenaPlanQueueJudgment.liveSuites(from: queued)
    }

    private var queueFace: ArenaQueueFace {
        ArenaPlanQueueJudgment.queueFace(queuedSuiteCount: queuedSuites.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(
                text: "Aguardando execução",
                tone: queueFace.productWord == "empty" ? .neutral : .active,
                showsLiveMark: queueFace.productWord != "empty"
            )
            .accessibilityIdentifier(A11yID.arenaPremiumQueue)
            HStack(alignment: .lastTextBaseline) {
                Text("\(queuedSuites.count)")
                    .font(AtlasFont.serif(58))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(queuedSuites.count == 1 ? "suíte na fila" : "suítes na fila")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .accessibilityValue(queueFace.productWord)
            .accessibilityLabel(queueFace.spokenFace)
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
            if case .empty = queueFace {
                Text("Fila vazia")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
                    .accessibilityValue(ArenaQueueFace.empty.productWord)
            }
        }
    }

    private func queueDetail(_ suite: String) -> String {
        let runs = queued.filter { $0.suite == suite }
        var seenArms = Set<String>()
        let arms = runs.compactMap(\.arm)
            .compactMap { seenArms.insert($0.rawValue).inserted ? $0.labelPT : nil }
        let engine = runs.first.map { ArenaDisplay.engine($0.engineDisplayName) }
        return ([engine] + arms).compactMap(\.self).joined(separator: " · ")
    }
}
