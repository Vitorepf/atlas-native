import SwiftUI
import AtlasCore

// Loaded sections — peel de AtlasArenaView+Content.
// Tail → AtlasArenaView+LoadedTail.swift

extension AtlasArenaView {
    @ViewBuilder
    func loadedArenaContent(_ composite: AtlasArenaComposite) -> some View {
        ArenaNowSection(liveRuns: model.liveRuns, reduceMotion: reduceMotion)
        if showsIndexSection(composite) {
            ArenaIndexSection(
                composite: composite,
                reduceMotion: reduceMotion,
                onEngineTap: { selectedEngine = $0 }
            )
        }
        ArenaCapabilitiesSection(capabilities: model.capabilities, reduceMotion: reduceMotion)
        loadedArenaTail(composite)
    }
}
