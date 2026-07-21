import SwiftUI
import Charts
import AtlasCore

// IDLE-COMPRESS — histórico do índice (marks + chrome + a11y).

struct ArenaCompositeChart: View {
    let engine: AtlasArenaCompositeEngine
    let reduceMotion: Bool

    var interpolation: InterpolationMethod { reduceMotion ? .linear : .catmullRom }

    var body: some View {
        Chart {
            historyMarks
        }
        .chartLegend(.visible)
        .chartXAxis(.hidden)
        .chartYScale(domain: fittedYDomain)
        .chartYAxis { AxisMarks(position: .leading) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteJudgment.spokenCompositeChart(engine))
    }

    /// Domínio ajustado ao dado: eixo fixo 0–1 espremia as linhas.
    var fittedYDomain: ClosedRange<Double> {
        let values = engine.history.flatMap { [$0.composite, $0.withAtlas, $0.withoutAtlas].compactMap { $0 } }
        guard let lo = values.min(), let hi = values.max(), hi > lo else { return 0 ... 1 }
        let pad = max(0.04, (hi - lo) * 0.3)
        return max(0, lo - pad) ... min(1, hi + pad)
    }

    @ChartContentBuilder
    var historyMarks: some ChartContent {
        ForEach(engine.history) { point in
            if let composite = point.composite {
                LineMark(x: .value("rodada", point.roundAt), y: .value("composto", composite))
                    .foregroundStyle(AtlasTheme.accent)
                    .interpolationMethod(interpolation)
            }
            if let withAtlas = point.withAtlas {
                LineMark(
                    x: .value("rodada", point.roundAt),
                    y: .value("com Atlas", withAtlas),
                    series: .value("série", "com Atlas")
                )
                .foregroundStyle(AtlasTheme.accent.opacity(0.65))
                .interpolationMethod(interpolation)
            }
            if let withoutAtlas = point.withoutAtlas {
                LineMark(
                    x: .value("rodada", point.roundAt),
                    y: .value("sem Atlas", withoutAtlas),
                    series: .value("série", "sem Atlas")
                )
                .foregroundStyle(AtlasTheme.textSecondary)
                .interpolationMethod(interpolation)
            }
        }
    }
}
