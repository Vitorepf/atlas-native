import SwiftUI
import Charts
import AtlasCore

// Resumo composto do motor — peel de ArenaEngineSheet (régua ≤100).
// Scores → ArenaEngineSheet+ScoreRow.swift

extension ArenaEngineSheet {
    var engineSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("composto")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Spacer()
                Text(ArenaFormat.score(engine.composite))
                    .font(AtlasFont.mono(20))
                    .foregroundStyle(engine.composite == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
            }
            engineScoreRow
            if !engine.history.isEmpty {
                Chart(engine.history) { point in
                    if let composite = point.composite {
                        LineMark(x: .value("rodada", point.roundAt), y: .value("composto", composite))
                            .foregroundStyle(AtlasTheme.accent)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis { AxisMarks(position: .leading) }
                .frame(height: 150)
                .accessibilityHidden(true)
            }
        }
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaEngineSheetA11y.spokenSummary(engine))
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: engine.history.count)
    }
}
