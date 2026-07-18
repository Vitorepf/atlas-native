import SwiftUI
import Charts
import AtlasCore

// Chart chrome — peel de ArenaCompositeChart.

extension ArenaCompositeChart {
    var compositeChartChrome: some View {
        Chart {
            historyMarks
        }
        .chartLegend(.visible)
        .chartXAxis(.hidden)
        .chartYScale(domain: 0 ... 1)
        .chartYAxis { AxisMarks(position: .leading, values: [0, 0.5, 1]) }
        .accessibilityHidden(true)
    }
}
