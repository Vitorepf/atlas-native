import SwiftUI
import AtlasCore

struct ArenaPremiumExecutionView: View {
    @Bindable var model: ArenaModel
    let onStop: (AtlasArenaLiveRun) -> Void

    private var runs: [AtlasArenaLiveRun] { model.arenaPrimaryMeasurementRuns }
    private var primary: AtlasArenaLiveRun? { model.arenaPrimaryRun }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
                .accessibilityIdentifier(A11yID.arenaPremiumExecution)
            progress
            control
            ArenaPremiumHairline()
            pipeline
            ArenaPremiumHairline()
            ArenaPremiumKicker(text: "Corridas")
            runRows
        }
    }

    private var pipeline: some View {
        VStack(alignment: .leading, spacing: 14) {
            ArenaPremiumKicker(text: "Pipeline")
            HStack(alignment: .top, spacing: 0) {
                stage("Preparar", symbol: "checkmark.circle", state: .done)
                stageConnector(done: true)
                stage("Sem Atlas", symbol: "checkmark", state: baselineStage)
                stageConnector(done: baselineStage == .done)
                stage("Com Atlas", symbol: "play.circle", state: atlasStage)
                stageConnector(done: atlasStage == .done)
                stage("Consolidar", symbol: "circle", state: consolidationStage)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(text: statusLabel, tone: statusTone, showsDot: true)
            Text(ArenaDisplay.engine(primary?.engineDisplayName ?? model.preferredEngine ?? "Arena"))
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text("Ordem, estado e progresso confirmados pelo servidor.")
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    @ViewBuilder
    private var progress: some View {
        if let value = model.livePresentation?.progress {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(value.completed)")
                    .font(AtlasFont.serif(56))
                Text("de \(value.total) casos")
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Spacer()
                Text("\(Int((value.fraction * 100).rounded(.down)))%")
                    .font(AtlasFont.mono(18, .medium))
                    .foregroundStyle(AtlasTheme.accent)
            }
            .foregroundStyle(AtlasTheme.textPrimary)
        } else {
            Text("Sem denominador publicado")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    @ViewBuilder
    private var control: some View {
        if let primary,
           primary.canStop == true,
           primary.measurementIdPublic != nil {
            ArenaPremiumAction(
                title: "Parar após o caso atual",
                symbol: ArenaPremiumIconography.stop,
                tone: .neutral
            ) {
                onStop(primary)
            }
        }
    }

    private var runRows: some View {
        VStack(spacing: 0) {
            if runs.isEmpty {
                Text("Nenhuma corrida publicada.")
                    .font(.system(.callout))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            } else {
                ForEach(runs) { run in
                    HStack(alignment: .top, spacing: 12) {
                        ArenaPremiumIcon(
                            symbol: ArenaPremiumIconography.run(run.status),
                            tone: tone(run.status)
                        )
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ArenaDisplay.suite(run.suite))
                                .font(.system(.callout, weight: .medium))
                                .foregroundStyle(AtlasTheme.textPrimary)
                            // Estado fala UMA vez (no trailing) — a sublinha
                            // repetia "na fila, ainda não iniciado" literal.
                            Text([run.arm?.labelPT, run.progressText == run.status.displayPT ? nil : run.progressText].compactMap(\.self).joined(separator: " · "))
                                .font(AtlasFont.mono(10))
                                .foregroundStyle(AtlasTheme.textSecondary)
                        }
                        Spacer()
                        Text(run.status.displayPT)
                            .font(AtlasFont.mono(10, .medium))
                            .foregroundStyle(tone(run.status).color)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.vertical, 14)
                    .accessibilityIdentifier(A11yID.arenaPremiumExecutionRun(run.runIdPublic))
                    ArenaPremiumHairline()
                }
            }
        }
    }

    // Bloco "Garantias" morto: honestidade se MOSTRA (estados literais,
    // parciais como parciais), não se declara — UI falando de si é ruído.

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

    private enum StageState: Equatable {
        case waiting
        case active
        case done
    }

    private var baselineStage: StageState {
        let baseline = runs.filter { $0.arm == .baseline }
        if baseline.contains(where: { $0.status == .running || $0.status == .stopping }) { return .active }
        if !baseline.isEmpty, baseline.allSatisfy({ $0.status == .completed }) { return .done }
        if runs.contains(where: { $0.arm == .withAtlas && $0.status != .queued }) { return .done }
        return .waiting
    }

    private var atlasStage: StageState {
        let atlas = runs.filter { $0.arm == .withAtlas }
        if atlas.contains(where: { $0.status == .running || $0.status == .stopping }) { return .active }
        if !atlas.isEmpty, atlas.allSatisfy({ $0.status == .completed }) { return .done }
        return .waiting
    }

    private var consolidationStage: StageState {
        guard !runs.isEmpty else { return .waiting }
        if runs.allSatisfy({ $0.status == .completed }) { return .done }
        return .waiting
    }

    private func stage(_ title: String, symbol: String, state: StageState) -> some View {
        VStack(spacing: 7) {
            ArenaPremiumIcon(
                symbol: state == .done ? "checkmark.circle" : (state == .active ? symbol : "circle"),
                tone: state == .waiting ? .muted : .active
            )
            Text(title)
                .font(AtlasFont.mono(8, state == .active ? .medium : .regular))
                .foregroundStyle(state == .waiting ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
    }

    private func stageConnector(done: Bool) -> some View {
        Rectangle()
            .fill(done ? AtlasTheme.accent.opacity(0.7) : AtlasTheme.separator)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
            .padding(.top, 8)
    }
}
