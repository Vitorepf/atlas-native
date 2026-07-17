import SwiftUI
import AtlasCore

// Conteúdo do índice — peel de ArenaIndexSection.
// Stack → ArenaIndexSection+Content+Stack.swift

extension ArenaIndexSection {
    var indexContent: some View {
        indexContentCardChrome(indexContentStack)
    }
}
