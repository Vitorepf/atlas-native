import SwiftUI
import AtlasCore

// Index stack — peel de ArenaIndexSection+Content.
// Header → ArenaIndexSection+Content+Stack+Header.swift
// Rows → ArenaIndexSection+Content+Stack+Rows.swift
// Chart → ArenaIndexSection+Content+Stack+Chart.swift

extension ArenaIndexSection {
    var indexContentStack: some View {
        VStack(alignment: .leading, spacing: 14) {
            indexContentHeaderBlock
            indexContentRowsBlock
            indexContentChartBlock
        }
    }
}
