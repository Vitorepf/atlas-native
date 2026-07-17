import SwiftUI
import PhotosUI
import AtlasCore

// Composer fade shell — peel de ConversationComposer.

extension ConversationComposer {
    var composerShell: some View {
        VStack(alignment: .leading, spacing: 0) {
            composerCard
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: model.isSending)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(composerFadeBackground)
    }
}
