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
        .chartYAxis { AxisMarks(position: .leading) }
        .accessibilityHidden(true)
    }
}
