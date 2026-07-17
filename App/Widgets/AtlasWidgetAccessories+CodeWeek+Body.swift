import WidgetKit
import SwiftUI
import AtlasCore

// Corpo da semana — peel de CodeWeekWidgetView.
// Metric → AtlasWidgetAccessories+CodeWeek+Metric.swift
// Quiet → AtlasWidgetAccessories+CodeWeek+Quiet.swift
// Header → AtlasWidgetAccessories+CodeWeek+Header.swift
// Hint → AtlasWidgetAccessories+CodeWeek+Hint.swift

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekBody(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            weekHeader(week: week, stale: stale, age: age)
            weekMetricsOrQuiet(week)
            weekLargeHint(week)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(CodeWeekWidgetA11y.spokenLabel(week: week, stale: stale, age: age))
    }
}
