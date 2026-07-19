import SwiftUI
import AtlasCore

struct ArenaPremiumRunningView: View {
    @Bindable var model: ArenaModel
    let onNavigate: (ArenaPremiumDestination) -> Void
    let onStop: (AtlasArenaLiveRun) -> Void

    private var run: AtlasArenaLiveRun? { model.arenaPrimaryRun }
    private var progress: AtlasArenaLiveProgress? { model.livePresentation?.progress }
    private var percentage: Int? {
        // Sem caso concluído não há percentual que mereça 50pt — o anel
        // mostra o ✦ e a cópia diz "começando".
        progress.flatMap { $0.completed == 0 ? nil : Int(($0.fraction * 100).rounded(.down)) }
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
            ArenaPremiumKicker(text: "Ao vivo", tone: .active, showsDot: true)
                .accessibilityIdentifier(A11yID.arenaPremiumState("running"))
            Text(ArenaDisplay.engine(run?.engineDisplayName ?? model.preferredEngine ?? "motor"))
                .font(AtlasFont.serif(31))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
            Text(
                [run.map { ArenaDisplay.suite($0.suite) }, run?.arm?.labelPT]
                    .compactMap(\.self)
                    .joined(separator: " · ")
            )
            .font(AtlasFont.mono(13))
            .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private var progressHero: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 24) {
                ArenaPremiumProgressRing(progress: progress?.fraction, percentage: percentage)
                progressCopy
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
                Text("\(progress.completed)/\(progress.total) casos")
                    .font(AtlasFont.mono(14, .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("\(progress.remaining) restantes")
                    .font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textSecondary)
            } else {
                Text("Progresso indeterminado")
                    .font(AtlasFont.mono(13, .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
            }
            Text(progress?.completed == 0 ? "começando…" : "tempo restante indisponível")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    private var actions: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                ArenaPremiumAction(title: "Ver execução", symbol: "list.bullet.rectangle") {
                    onNavigate(.execution)
                }
                .accessibilityIdentifier(A11yID.arenaPremiumExecutionAction)
                stopButton
            }
            VStack(alignment: .leading, spacing: 10) {
                ArenaPremiumAction(title: "Ver execução", symbol: "list.bullet.rectangle") {
                    onNavigate(.execution)
                }
                .accessibilityIdentifier(A11yID.arenaPremiumExecutionAction)
                stopButton
            }
        }
    }

    @ViewBuilder
    private var stopButton: some View {
        if let run,
           run.canStop == true,
           run.measurementIdPublic != nil {
            ArenaPremiumAction(title: "Parar", symbol: "stop.fill", tone: .neutral) {
                onStop(run)
            }
            .accessibilityIdentifier(A11yID.arenaPremiumStop)
        }
    }
}
