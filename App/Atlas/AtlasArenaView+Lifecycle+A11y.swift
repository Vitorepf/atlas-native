import SwiftUI
import AtlasCore

// Arena a11y chrome — peel de AtlasArenaView+Lifecycle.

extension AtlasArenaView {
    func arenaLifecycleA11y<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Arena")
            .navigationBarTitleDisplayMode(.inline)
            // O título de navegação já anuncia a superfície. Label/ID no
            // container inteiro substituía o nome e o ID de cada tab e CTA.
    }
}
