import SwiftUI
import Charts
import AtlasCore

// Gráfico de histórico do índice — peel de ArenaIndexSection (régua ~120).
// Marks → ArenaCompositeChart+Marks.swift

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
        .chartYAxis { AxisMarks(position: .leading) }
        .accessibilityHidden(true)
    }
}
