import SwiftUI
import PhotosUI
import AtlasCore

// Composer padding — peel de ConversationComposer+Shell.

extension ConversationComposer {
    @ViewBuilder
    var composerShellPadding: some View {
        composerShellVBox
            .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: model.isSending)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
            .background(composerFadeBackground)
    }
}
