import SwiftUI
import PhotosUI
import AtlasCore

// Page a11y chrome — peel de ConversationView+Page.

extension ConversationView {
    func conversationPageChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .scrollDismissesKeyboard(.interactively)
            .accessibilityIdentifier(A11yID.conversationScreen)
            .accessibilityLabel(spokenConversationScreenLabel())
            .accessibilityHint(
                hidesNavigationBack
                    ? "arraste para baixo para fechar"
                    : ConversationViewA11y.screenHint
            )
            .overlay(alignment: .top) { toast }
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.toast)
    }
}
