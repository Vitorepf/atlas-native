import SwiftUI
import AtlasCore

// Outline sheet — peel de ConversationView+Lifecycle.

extension ConversationView {
    func conversationOutlineSheet<Content: View>(_ content: Content) -> some View {
        content.sheet(isPresented: $showOutline) {
            ConversationOutlineSheet(bubbles: model.bubbles, reduceMotion: reduceMotion)
        }
    }
}
