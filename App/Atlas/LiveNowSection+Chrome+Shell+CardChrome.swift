import SwiftUI
import AtlasCore

// Card chrome — peel de LiveNowSection+Chrome+Shell.

extension LiveNowSection {
    @ViewBuilder
    func liveNowSectionCardChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(14)
            .atlasCard()
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 18)
    }
}
