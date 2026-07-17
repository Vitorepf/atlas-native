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
                        Spacer()
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(runAccessibilityLabel(run))
                    .transition(reduceMotion ? .opacity : .asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 6)),
                        removal: .opacity
                    ))
                }
                Text("Seguir medição na Live Activity: pendente de ActivityKit dedicado para Arena.")
                    .font(.system(.caption))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityLabel("Seguir medição na Live Activity pendente de contrato dedicado para Arena")
            }
            .padding(16)
            .atlasCard()
            .accessibilityIdentifier(A11yID.arenaNowSection)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: runs.map(\.id))
        }
    }

    @ViewBuilder
    private func statusIndicator(for run: AtlasArenaLiveRun) -> some View {
        switch run.status {
        case .running:
            if reduceMotion {
                Circle()
                    .fill(AtlasTheme.accent)
                    .frame(width: 8, height: 8)
            } else {
                BreathingDiamond(size: 8, reduceMotion: false)
                    .frame(width: 8, height: 8)
            }
        default:
            Circle()
                .fill(AtlasTheme.textTertiary)
                .frame(width: 8, height: 8)
        }
    }

    private func runAccessibilityLabel(_ run: AtlasArenaLiveRun) -> String {
        let arm = run.arm?.labelPT ?? "braço desconhecido"
        let progress = run.progressText
        return "\(run.suite), \(run.engineDisplayName), \(arm), \(run.status.displayPT), \(progress)"
    }
}
