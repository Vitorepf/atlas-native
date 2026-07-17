import SwiftUI
import Charts
import AtlasCore

// MARK: - Arena suite rows + sparkline (peel de ArenaSuitesSection)

struct ArenaSuiteRow: View {
    let suite: AtlasArenaSuite

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(suite.suite.uppercased())
                        .font(AtlasFont.mono(12))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .lineLimit(1)
                    if !suite.adapterInstalled {
                        Text("sem adapter")
                            .font(AtlasFont.mono(9))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    if suite.hasRegression {
                        Circle().fill(AtlasTheme.alert).frame(width: 7, height: 7)
                            .accessibilityLabel("regressão")
                    }
                }
                Text(subtitle)
                    .font(.system(.caption))
                    .foregroundStyle(suite.isMeasured ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            if let engine = suite.engines.first,
               engine.history.contains(where: { $0.score != nil }) {
                SuiteSparkline(engine: engine).frame(width: 64, height: 30)
            } else if suite.isMeasured {
                Text("medido")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            } else {
                Text("não medido")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private var subtitle: String {
        suite.arenaSubtitleText
    }
}

extension AtlasArenaSuite {
    var arenaSubtitleText: String {
        guard isMeasured else { return "não medido" }
        let rounds = runsTotal == 1 ? "1 rodada" : "\(runsTotal) rodadas"
        if let lastRunAt { return "\(rounds) · \(lastRunAt)" }
        return rounds
    }
}

/// Sparkline compartilhado pela row e por `ArenaSuiteSheet` (módulo interno).
struct SuiteSparkline: View {
    let engine: AtlasArenaSuiteEngine

    var body: some View {
        Chart(engine.history) { point in
            if let score = point.score {
                LineMark(x: .value("rodada", point.roundAt), y: .value("score", score))
                    .foregroundStyle(point.arm == .withAtlas ? AtlasTheme.accent : AtlasTheme.textSecondary)
                    .interpolationMethod(.linear)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .accessibilityHidden(true)
    }
}
