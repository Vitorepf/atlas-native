import WidgetKit
import SwiftUI
import AtlasCore

// Metrics stack — peel de CodeWeek+Quiet.
// Primary → AtlasWidgetAccessories+CodeWeek+Quiet+MetricsStack+Primary.swift

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekMetricsStack(_ week: AtlasNativeSnapshot.Week) -> some View {
        HStack(spacing: 14) {
            weekMetricsPrimary(week)
            if week.prevented > 0 { weekMetric("\(week.prevented)", "prevenidos") }
        }
    }
}
