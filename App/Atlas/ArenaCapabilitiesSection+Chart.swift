import SwiftUI
import Charts
import AtlasCore

// Capabilities chart — peel de ArenaCapabilitiesSection+Rows.

struct ArenaCapabilitiesChart: View {
    let capabilities: [AtlasArenaCapability]

    private struct Point: Identifiable {
        let id = UUID()
        let label: String
        let series: String
        let value: Double
    }

    private var points: [Point] {
        capabilities.flatMap { capability in
            [
                capability.score.map { Point(label: capability.labelPt, series: "sem Atlas", value: $0) },
                capability.withAtlas.map { Point(label: capability.labelPt, series: "com Atlas", value: $0) },
            ].compactMap { $0 }
        }
    }

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
