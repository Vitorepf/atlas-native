import SwiftUI
import AtlasCore

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
