import WidgetKit
import SwiftUI
import AtlasCore

// Corpo da semana — peel de CodeWeekWidgetView.
// Metric → AtlasWidgetAccessories+CodeWeek+Metric.swift
// Quiet → AtlasWidgetAccessories+CodeWeek+Quiet.swift
// Header → AtlasWidgetAccessories+CodeWeek+Header.swift

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekBody(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            weekHeader(week: week, stale: stale, age: age)
            weekMetricsOrQuiet(week)
            if family == .systemLarge {
                Text(CodeWeekWidgetA11y.isQuiet(week)
                     ? "abra o radar do Código para ver o grafo"
                     : "abra o radar do Código para o grafo")
                    .font(.system(size: 12, design: .serif))
                    .foregroundStyle(Ink.ink2)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(CodeWeekWidgetA11y.spokenLabel(week: week, stale: stale, age: age))
    }
}
