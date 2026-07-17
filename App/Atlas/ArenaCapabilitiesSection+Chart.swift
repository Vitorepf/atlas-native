import SwiftUI
import Charts
import AtlasCore

// Capabilities chart — peel de ArenaCapabilitiesSection+Rows.
// Points → ArenaCapabilitiesSection+ChartPoints.swift

struct ArenaCapabilitiesChart: View {
    let capabilities: [AtlasArenaCapability]

    var body: some View {
        if !points.isEmpty {
            Chart(points) { point in
                BarMark(x: .value("score", point.value), y: .value("capacidade", point.label))
                    .position(by: .value("série", point.series))
                    .foregroundStyle(point.series == "com Atlas" ? AtlasTheme.accent : AtlasTheme.textSecondary)
            }
            .chartXScale(domain: 0...1)
            .chartLegend(.visible)
            .chartXAxis { AxisMarks(values: [0, 0.5, 1]) }
            .chartYAxis(.hidden)
            .accessibilityHidden(true)
        }
    }
}
