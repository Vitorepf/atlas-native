import SwiftUI
import AtlasCore

struct ArenaNowSection: View {
    let liveRuns: AtlasArenaLiveRuns?

    var body: some View {
        if let runs = liveRuns?.runs, !runs.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("AGORA")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                ForEach(runs) { run in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(run.status == .running ? AtlasTheme.accent : AtlasTheme.textTertiary)
                            .frame(width: 8, height: 8)
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
                    .accessibilityLabel("\(run.suite), \(run.engineDisplayName), \(run.arm?.labelPT ?? "braço desconhecido"), \(run.status.displayPT)")
                }
                Text("Seguir medição na Live Activity: pendente de ActivityKit dedicado para Arena.")
                    .font(.system(.caption))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityLabel("Seguir medição na Live Activity pendente de contrato dedicado para Arena")
            }
            .padding(16)
            .atlasCard()
        }
    }
}
