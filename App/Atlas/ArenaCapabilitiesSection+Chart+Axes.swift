import SwiftUI
import Charts
import AtlasCore

// Chart axes — peel de ArenaCapabilitiesSection+Chart.

extension ArenaCapabilitiesChart {
    func capabilitiesChartAxes<Content: View>(_ chart: Content) -> some View {
        chart
            .chartXScale(domain: 0...1)
            .chartLegend(.visible)
            .chartXAxis { AxisMarks(values: [0, 0.5, 1]) }
            .chartYAxis(.hidden)
            .accessibilityHidden(true)
    }
}
