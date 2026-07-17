import WidgetKit
import SwiftUI
import AtlasCore

// Commits/heals metrics — peel de CodeWeek Quiet MetricsStack.

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekMetricsPrimary(_ week: AtlasNativeSnapshot.Week) -> some View {
        if week.commits > 0 { weekMetric("\(week.commits)", "commits") }
        if week.heals > 0 { weekMetric("\(week.heals)", "curas") }
    }
}
