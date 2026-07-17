import SwiftUI
import AtlasCore

// Bubbles stack a11y — peel de ConversationMessages+BubblesStack.

extension ConversationMessages {
    func bubblesStackA11y<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ConversationMessagesA11y.spokenMessages(turnCount: model.bubbles.count))
    }
}
