import SwiftUI
import Charts
import AtlasCore

// Capabilities chart — peel de ArenaCapabilitiesSection+Rows.
// Points → ArenaCapabilitiesSection+ChartPoints.swift
// BarMark → ArenaCapabilitiesSection+Chart+BarMark.swift
// Axes → ArenaCapabilitiesSection+Chart+Axes.swift

struct ArenaCapabilitiesChart: View {
    let capabilities: [AtlasArenaCapability]

    var body: some View {
        if !points.isEmpty {
            capabilitiesChartAxes(capabilitiesBarChart)
        }
    }
}
