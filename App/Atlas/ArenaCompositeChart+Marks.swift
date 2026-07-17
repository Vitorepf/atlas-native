import SwiftUI
import Charts
import AtlasCore

// Chart marks — peel de ArenaCompositeChart.

extension ArenaCompositeChart {
    @ChartContentBuilder
    var historyMarks: some ChartContent {
        ForEach(engine.history) { point in
            compositeMark(for: point)
            atlasSeriesMarks(for: point)
        }
    }
}
