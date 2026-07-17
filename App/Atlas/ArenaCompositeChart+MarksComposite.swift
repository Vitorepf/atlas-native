import SwiftUI
import Charts
import AtlasCore

// Composite mark — peel de ArenaCompositeChart+Marks.

extension ArenaCompositeChart {
    @ChartContentBuilder
    func compositeMark(for point: AtlasArenaCompositePoint) -> some ChartContent {
        if let composite = point.composite {
            LineMark(x: .value("rodada", point.roundAt), y: .value("composto", composite))
                .foregroundStyle(AtlasTheme.accent)
                .interpolationMethod(interpolation)
        }
    }
}
