import WidgetKit
import SwiftUI
import AtlasCore

// Corpo quieto / métricas — peel de CodeWeek+Body.

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekMetricsOrQuiet(_ week: AtlasNativeSnapshot.Week) -> some View {
        if CodeWeekWidgetA11y.isQuiet(week) {
            Text("semana quieta · sem commits nem curas")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink2)
                .lineLimit(2)
        } else {
            HStack(spacing: 14) {
                if week.commits > 0 { weekMetric("\(week.commits)", "commits") }
                if week.heals > 0 { weekMetric("\(week.heals)", "curas") }
                if week.prevented > 0 { weekMetric("\(week.prevented)", "prevenidos") }
            }
        }
    }
}
