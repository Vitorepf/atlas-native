import SwiftUI
import AtlasCore

// Conteúdo do índice — peel de ArenaIndexSection.
// Rows → ArenaIndexSection+ContentRows.swift

extension ArenaIndexSection {
    var indexContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader
            engineRows
            if let engine = chartEngine {
                ArenaCompositeChart(engine: engine, reduceMotion: reduceMotion)
                    .frame(height: 170)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(sectionSpokenLabel)
        .accessibilityIdentifier(A11yID.arenaIndexSection)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: composite.engines.map(\.id))
    }
}
