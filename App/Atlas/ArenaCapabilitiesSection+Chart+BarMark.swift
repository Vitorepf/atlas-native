import SwiftUI
import Charts
import AtlasCore

// Bar marks — peel de ArenaCapabilitiesSection+Chart.

extension ArenaCapabilitiesChart {
    var capabilitiesBarChart: some View {
        Chart(points) { point in
            BarMark(x: .value("score", point.value), y: .value("capacidade", point.label))
                .position(by: .value("série", point.series))
                .foregroundStyle(point.series == "com Atlas" ? AtlasTheme.accent : AtlasTheme.textSecondary)
        }
    }
}
