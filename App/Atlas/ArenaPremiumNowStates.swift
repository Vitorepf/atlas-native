import SwiftUI
import AtlasCore

// MARK: - Host

struct ArenaPremiumIdleView: View {
    @Bindable var model: ArenaModel
    let onRun: () -> Void
    let onNavigate: (ArenaPremiumDestination) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumEmptyGlyph(symbol: "scope")
                .accessibilityIdentifier(A11yID.arenaPremiumState("idle"))
            ArenaPremiumKicker(text: ArenaNowJudgment.idleKicker())
            Text(ArenaNowJudgment.idleTitle())
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(ArenaNowJudgment.idleBody())
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityValue(ArenaNowFace.idle.productWord)
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
            ArenaPremiumKicker(text: ArenaNowJudgment.queuedKicker(), tone: .active, showsDot: true)
                .accessibilityIdentifier(A11yID.arenaPremiumState("queued"))
            Text(ArenaNowJudgment.queuedTitle())
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityValue(ArenaNowFace.queued.productWord)
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
            Text(ArenaNowJudgment.queuedHonestyLine())
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
    }
}

// MARK: - Peels

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

    /// WAVE-066: terminal chrome from ArenaNowJudgment.
    private var chrome: ArenaNowTerminalChrome {
        ArenaNowJudgment.terminalChrome(kind)
    }

    private var nowFace: ArenaNowFace {
        ArenaNowJudgment.face(terminal: kind)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumEmptyGlyph(symbol: chrome.symbol, tone: chrome.tone)
                .accessibilityIdentifier(A11yID.arenaPremiumState(stateIdentifier))
            ArenaPremiumKicker(text: chrome.title, tone: chrome.tone)
            Text(model.arenaLiveEngineTitle)
                .font(AtlasFont.serif(33))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(chrome.subtitle)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityValue(nowFace.productWord)
                .accessibilityLabel(nowFace.spokenFace)
            if let progress = model.livePresentation?.progress {
                HStack(alignment: .lastTextBaseline, spacing: 7) {
                    Text("\(progress.completed)")
                        .font(AtlasFont.serif(44))
                    Text("de \(progress.total) casos confirmados")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .foregroundStyle(AtlasTheme.textPrimary)
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
