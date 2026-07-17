import WidgetKit
import SwiftUI
import AtlasCore

// Métricas da semana — peel de CodeWeekWidgetView.

extension CodeWeekWidgetView {
    func weekMetric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink)
            Text(label)
                .font(.system(size: 10, design: .serif))
                .foregroundStyle(Ink.ink2)
        }
    }

    @ViewBuilder
    func weekBody(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("✦ Semana")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                Spacer()
                Text(week.window)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Ink.ink2)
            }
            if stale {
                Text("visto \(age)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Ink.alert)
            }
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
