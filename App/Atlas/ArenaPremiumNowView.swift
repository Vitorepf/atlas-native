import SwiftUI
import AtlasCore

struct ArenaPremiumNowView: View {
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
        .accessibilityIdentifier(A11yID.arenaPremiumState("loading"))
    }

    @ViewBuilder
    private var loadingIndicator: some View {
        if UIAccessibility.isReduceMotionEnabled {
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
