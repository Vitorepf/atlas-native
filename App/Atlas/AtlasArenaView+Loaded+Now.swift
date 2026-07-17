import SwiftUI
import AtlasCore

// Now section — peel de AtlasArenaView+Loaded.

extension AtlasArenaView {
    @ViewBuilder
    func loadedArenaNowSection(_ composite: AtlasArenaComposite) -> some View {
        ArenaNowSection(liveRuns: model.liveRuns, reduceMotion: reduceMotion)
    }
}
