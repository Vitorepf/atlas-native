import SwiftUI
import AtlasCore

struct ArenaPremiumNowView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
            ArenaPremiumKicker(text: "Preparando a Arena", tone: .active, showsDot: true)
            Text("Organizando as medições")
                .font(AtlasFont.serif(32))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            loadingIndicator
            Text("Índice, execução e capacidades chegam por contratos independentes.")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Preparando a Arena. Organizando as medições.")
        .accessibilityAddTraits(reduceMotion ? .isStaticText : [.isStaticText, .updatesFrequently])
        .accessibilityIdentifier(A11yID.arenaPremiumState("loading"))
    }

    @ViewBuilder
    private var loadingIndicator: some View {
        if reduceMotion {
            Text("carregando…")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        } else {
            ProgressView()
                .tint(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }
}


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
                .accessibilityAddTraits(.isHeader)
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            subtitle.isEmpty
                ? "Ao vivo, \(engineTitle)"
                : "Ao vivo, \(engineTitle), \(subtitle)"
        )
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(progressSpoken)
    }

    private var progressSpoken: String {
        if let progress {
            return "\(progress.completed) de \(progress.total) casos confirmados, \(progress.remaining) restantes"
        }
        return "Progresso indeterminado, denominador ainda não publicado"
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumAction(title: "Ver execução", tone: .neutral) {
                onNavigate(.execution)
            }
            .accessibilityIdentifier(A11yID.arenaPremiumExecutionAction)
            if let run,
               run.canStop == true,
               run.measurementIdPublic != nil {
                ArenaPremiumAction(title: "Parar após o caso atual", quiet: true) {
                    onStop(run)
                }
                .accessibilityIdentifier(A11yID.arenaPremiumStop)
            }
        }
    }
}


struct ArenaPremiumIdleView: View {
    @Bindable var model: ArenaModel
    let onRun: () -> Void
    let onNavigate: (ArenaPremiumDestination) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ArenaPremiumEmptyGlyph(symbol: "scope")
                .accessibilityIdentifier(A11yID.arenaPremiumState("idle"))
            ArenaPremiumKicker(text: "Arena pronta")
            Text("Nada medindo agora")
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Escolha os motores, as suítes e os braços. A Arena cuida da ordem e mostra apenas progresso confirmado.")
                .font(.system(.body))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(
                    "Escolha os motores, as suítes e os braços. A Arena cuida da ordem e mostra apenas progresso confirmado."
                )
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
            ArenaPremiumKicker(text: "Na fila", tone: .active, showsDot: true)
                .accessibilityIdentifier(A11yID.arenaPremiumState("queued"))
            Text("Medição programada")
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
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
            Text("Ainda não iniciado · nenhum progresso foi presumido.")
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(value) \(label)")
    }
}

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

    private var configuration: (String, String, String, ArenaPremiumTone) {
        switch kind {
        case .stopping:
            ("Parada solicitada", "Finalizando o caso atual", "hourglass", .active)
        case .stopped:
            ("Medição parada", "Resultados parciais preservados", "stop.circle", .neutral)
        case .completed:
            ("Medição concluída", "Resultado terminal confirmado", "checkmark.seal", .positive)
        case .failed:
            ("Medição interrompida", "O que concluiu foi preservado", "exclamationmark.triangle", .negative)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumEmptyGlyph(symbol: configuration.2, tone: configuration.3)
                .accessibilityIdentifier(A11yID.arenaPremiumState(stateIdentifier))
            ArenaPremiumKicker(text: configuration.0, tone: configuration.3)
            Text(model.arenaLiveEngineTitle)
                .font(AtlasFont.serif(33))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(configuration.1)
                .font(.system(.body))
                .foregroundStyle(AtlasTheme.textSecondary)
            if let progress = model.livePresentation?.progress {
                HStack(alignment: .lastTextBaseline, spacing: 7) {
                    Text("\(progress.completed)")
                        .font(AtlasFont.serif(44))
                    Text("de \(progress.total) casos confirmados")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(progress.completed) de \(progress.total) casos confirmados")
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


/// Agora ao vivo: zero inventário. Só o que o operador precisa agora —
/// progresso, um verbo (Ver execução), par se existir, alerta se doer.
struct ArenaPremiumOperationalRows: View {
    @Bindable var model: ArenaModel
    let onNavigate: (ArenaPremiumDestination) -> Void

    private var alertCount: Int { model.arenaAlertSuiteCount }

    var body: some View {
        // Sem exceção: some a seção. Fila/Cobertura/Próxima/Plano moram
        // DENTRO de Execução — duplicar aqui era a confusão.
        if alertCount > 0 {
            VStack(spacing: 0) {
                ArenaPremiumHairline()
                ArenaPremiumGlyphRow(
                    glyph: "※",
                    title: "Alertas",
                    detail: alertCount == 1 ? "1 exceção" : "\(alertCount) exceções",
                    tone: .negative,
                    glyphTone: .negative
                ) { onNavigate(.alerts) }
                .accessibilityIdentifier(A11yID.arenaPremiumAlertsAction)
            }
        }
    }
}
