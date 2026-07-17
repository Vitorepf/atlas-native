import SwiftUI
import AtlasCore

// Capabilities section — peel de AtlasArenaView+Loaded.

extension AtlasArenaView {
    @ViewBuilder
    func loadedArenaCapabilitiesSection(_ composite: AtlasArenaComposite) -> some View {
        ArenaCapabilitiesSection(capabilities: model.capabilities, reduceMotion: reduceMotion)
    }
}
