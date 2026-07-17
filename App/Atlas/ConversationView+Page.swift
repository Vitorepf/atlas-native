import SwiftUI
import PhotosUI
import AtlasCore

// Página editorial + composer — peel de ConversationView (régua ≤100).
// Chrome → ConversationView+PageChrome.swift
// Parts → ConversationView+PageParts.swift

extension ConversationView {
    @ViewBuilder
    var conversationPage: some View {
        conversationPageChrome(
            ZStack(alignment: .bottom) {
                AtlasTheme.bg.ignoresSafeArea()
                conversationMessagesStack
                conversationComposerBind
            }
        )
    }
}
