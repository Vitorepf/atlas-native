import SwiftUI
import Charts
import AtlasCore

// Resumo composto do motor — peel de ArenaEngineSheet (régua ≤100).
// Scores → ArenaEngineSheet+ScoreRow.swift
// History → ArenaEngineSheet+History.swift
// Header → ArenaEngineSheet+SummaryHeader.swift

extension ArenaEngineSheet {
    var engineSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            engineSummaryHeader
            engineScoreRow
            engineHistoryChart
        }
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaEngineSheetA11y.spokenSummary(engine))
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: engine.history.count)
    }
}
