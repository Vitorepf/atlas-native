import SwiftUI
import AtlasCore

// Engine nav chrome — peel de ArenaEngineSheet+ScrollBody.

extension ArenaEngineSheet {
    func engineScrollNavChrome<Content: View>(_ content: Content) -> some View {
        content
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Motor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { engineToolbar }
    }
}
