import SwiftUI
import AtlasCore

// Index section — peel de AtlasArenaView+Loaded.

extension AtlasArenaView {
    @ViewBuilder
    func loadedArenaIndexSection(_ composite: AtlasArenaComposite) -> some View {
        if showsIndexSection(composite) {
            ArenaIndexSection(
                composite: composite,
                reduceMotion: reduceMotion,
                onEngineTap: { selectedEngine = $0 }
            )
        }
    }
}
