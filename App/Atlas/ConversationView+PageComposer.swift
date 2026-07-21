import SwiftUI
import AtlasCore

// Conversation composer bind — peel de ConversationView+PageParts.
// Card → ConversationView+PageComposerCard.swift

extension ConversationView {
    var conversationComposerBind: some View {
        conversationComposerCard
    }
}
