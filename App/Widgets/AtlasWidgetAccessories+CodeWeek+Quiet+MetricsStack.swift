import WidgetKit
import SwiftUI
import AtlasCore

// Metrics stack — peel de CodeWeek+Quiet.

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekMetricsStack(_ week: AtlasNativeSnapshot.Week) -> some View {
        HStack(spacing: 14) {
            if week.commits > 0 { weekMetric("\(week.commits)", "commits") }
            if week.heals > 0 { weekMetric("\(week.heals)", "curas") }
            if week.prevented > 0 { weekMetric("\(week.prevented)", "prevenidos") }
        }
    }
}
