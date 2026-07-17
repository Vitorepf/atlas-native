import SwiftUI
import AtlasCore

/// AGORA — só existe com run vivo (spec §E). Sem runs = silêncio total (lei V1).
struct ArenaNowSection: View {
    let liveRuns: AtlasArenaLiveRuns?
    let reduceMotion: Bool

    private var runs: [AtlasArenaLiveRun] {
        liveRuns?.runs ?? []
    }

    var body: some View {
        if !runs.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("AGORA")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityAddTraits(.isHeader)
                ForEach(runs) { run in
                    HStack(spacing: 10) {
                        statusIndicator(for: run)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(run.suite) · \(run.engineDisplayName)")
                                .font(.system(.callout, weight: .medium))
                                .foregroundStyle(AtlasTheme.textPrimary)
                                .lineLimit(1)
                            Text("\(run.arm?.labelPT ?? "braço desconhecido") · \(run.progressText)")
                                .font(AtlasFont.mono(11))
                                .foregroundStyle(AtlasTheme.textSecondary)
                        }
                        .accessibilityHidden(true)
                        Spacer()
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(ArenaNowSectionA11y.spokenRun(run))
                    .accessibilityIdentifier(A11yID.arenaNowRun(run.runIdPublic))
                    .transition(reduceMotion ? .identity : .asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 6)),
                        removal: .opacity
                    ))
                }
                Text("Seguir medição na Live Activity: pendente de ActivityKit dedicado para Arena.")
                    .font(.system(.caption))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier(A11yID.arenaNowLiveActivityNote)
            }
            .padding(16)
            .atlasCard()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ArenaNowSectionA11y.spokenSection(runCount: runs.count))
            .accessibilityIdentifier(A11yID.arenaNowSection)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: runs.map(\.id))
        }
    }

    @ViewBuilder
    private func statusIndicator(for run: AtlasArenaLiveRun) -> some View {
        Group {
            if case .running = run.status {
                BreathingDiamond(size: 8, reduceMotion: reduceMotion)
            } else {
                Circle()
                    .fill(AtlasTheme.textTertiary)
            }
        }
        .frame(width: 8, height: 8)
        .accessibilityHidden(true)
    }
}
