import SwiftUI
import AtlasCore

/// Execução = o ÚNICO mapa da medição (mockup operador 2026-07-20).
/// Pipeline macro + casos da suíte ao vivo + corridas tocáveis.
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
