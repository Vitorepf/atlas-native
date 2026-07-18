import SwiftUI
import AtlasCore

// Loaded sections — peel de AtlasArenaView+Content.
// Tail → AtlasArenaView+LoadedTail.swift

extension AtlasArenaView {
    @ViewBuilder
    func loadedArenaContent(_ composite: AtlasArenaComposite) -> some View {
        // Ordem do goal 2026-07-17: capacidades são o hero — vêm antes do índice.
        loadedArenaNowSection(composite)
        loadedArenaCapabilitiesSection(composite)
        loadedArenaIndexSection(composite)
        loadedArenaTail(composite)
    }
}
