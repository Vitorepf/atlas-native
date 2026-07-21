import SwiftUI
import Charts
import AtlasCore

// Chart chrome — peel de ArenaCompositeChart.

extension ArenaCompositeChart {
    /// Domínio ajustado ao dado: eixo fixo 0–1 espremia as linhas numa
    /// faixa de 5% do plot (a tendência sumia). Eixo rotulado = honesto.
    var fittedYDomain: ClosedRange<Double> {
        let values = engine.history.flatMap { [$0.composite, $0.withAtlas, $0.withoutAtlas].compactMap { $0 } }
        guard let lo = values.min(), let hi = values.max(), hi > lo else { return 0 ... 1 }
        let pad = max(0.04, (hi - lo) * 0.3)
        return max(0, lo - pad) ... min(1, hi + pad)
    }

    var compositeChartChrome: some View {
        Chart {
            historyMarks
        }
        .chartLegend(.visible)
        .chartXAxis(.hidden)
        .chartYScale(domain: fittedYDomain)
        .chartYAxis { AxisMarks(position: .leading) }
        .accessibilityHidden(true)
    }
}
