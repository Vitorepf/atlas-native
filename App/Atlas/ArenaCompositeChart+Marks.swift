import SwiftUI
import Charts
import AtlasCore

// Chart marks — peel de ArenaCompositeChart.

extension ArenaCompositeChart {
    @ChartContentBuilder
    var historyMarks: some ChartContent {
        ForEach(engine.history) { point in
            if let composite = point.composite {
                LineMark(x: .value("rodada", point.roundAt), y: .value("composto", composite))
                    .foregroundStyle(AtlasTheme.accent)
                    .interpolationMethod(interpolation)
            }
            if let withAtlas = point.withAtlas {
                LineMark(x: .value("rodada", point.roundAt), y: .value("com Atlas", withAtlas), series: .value("série", "com Atlas"))
                    .foregroundStyle(AtlasTheme.accent.opacity(0.65))
                    .interpolationMethod(interpolation)
            }
            if let withoutAtlas = point.withoutAtlas {
                LineMark(x: .value("rodada", point.roundAt), y: .value("sem Atlas", withoutAtlas), series: .value("série", "sem Atlas"))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .interpolationMethod(interpolation)
            }
        }
    }
}
