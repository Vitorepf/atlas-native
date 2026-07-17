import SwiftUI
import Charts
import AtlasCore

// History chart — peel de ArenaEngineSheet+Summary.

extension ArenaEngineSheet {
    @ViewBuilder
    var engineHistoryChart: some View {
        if !engine.history.isEmpty {
            Chart(engine.history) { point in
                if let composite = point.composite {
                    LineMark(x: .value("rodada", point.roundAt), y: .value("composto", composite))
                        .foregroundStyle(AtlasTheme.accent)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis { AxisMarks(position: .leading) }
            .frame(height: 150)
            .accessibilityHidden(true)
        }
    }
}
