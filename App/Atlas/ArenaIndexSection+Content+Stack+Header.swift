import SwiftUI
import AtlasCore

// Index header block — peel de ArenaIndexSection+Content+Stack.
// Rows → ArenaIndexSection+Content+Stack+Rows.swift
// Chart → ArenaIndexSection+Content+Stack+Chart.swift

extension ArenaIndexSection {
    @ViewBuilder
    var indexContentHeaderBlock: some View {
        sectionHeader
    }
}
