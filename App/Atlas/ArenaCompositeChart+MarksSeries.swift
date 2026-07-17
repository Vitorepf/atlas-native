import SwiftUI
import Charts
import AtlasCore

// Atlas series marks — peel de ArenaCompositeChart+Marks.

extension ArenaCompositeChart {
    @ChartContentBuilder
    func atlasSeriesMarks(for point: AtlasArenaCompositePoint) -> some ChartContent {
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
