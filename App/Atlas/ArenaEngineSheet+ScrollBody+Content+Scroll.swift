import SwiftUI
import AtlasCore

// Scroll wrapper — peel de ArenaEngineSheet+ScrollBody+Content.
// Inner → ArenaEngineSheet+ScrollBody+Content+Inner.swift

extension ArenaEngineSheet {
    var engineScrollView: some View {
        ScrollView {
            engineScrollInnerStack
                .padding(AtlasTheme.Space.screen)
        }
    }
}
