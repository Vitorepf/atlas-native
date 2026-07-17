import SwiftUI
import AtlasCore

// Conteúdo do índice — peel de ArenaIndexSection.
// Rows → ArenaIndexSection+ContentRows.swift
// Chart → ArenaIndexSection+Content+Chart.swift
// CardChrome → ArenaIndexSection+Content+CardChrome.swift

extension ArenaIndexSection {
    var indexContent: some View {
        indexContentCardChrome(
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader
                engineRows
                indexContentChart
            }
        )
    }
}
