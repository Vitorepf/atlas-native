import SwiftUI
import Charts
import AtlasCore

// WAVE-010 fused Suite sparkline

// --- ArenaSuiteSparkline+Subtitle.swift ---
extension AtlasArenaSuite {
    var arenaSubtitleText: String {
        guard isMeasured else { return "não medido" }
        let rounds = runsTotal == 1 ? "1 rodada" : "\(runsTotal) rodadas"
        if let relative = ArenaDisplay.relative(lastRunAt) { return "\(rounds) · \(relative)" }
        return rounds
    }
}

// --- ArenaSuiteSparkline.swift ---
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

