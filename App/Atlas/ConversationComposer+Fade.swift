import SwiftUI
import PhotosUI
import AtlasCore

// Fade de fundo do composer — peel de ConversationComposer.

extension ConversationComposer {
    var composerFadeBackground: some View {
        LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}
