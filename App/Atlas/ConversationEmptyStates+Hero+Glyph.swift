import SwiftUI
import AtlasCore

// Hero glyph — peel de ConversationEmptyStates+Hero.

extension EmptyConversation {
    var heroGlyph: some View {
        Text("✦")
            .font(AtlasFont.serif(32)).foregroundStyle(AtlasTheme.accent)
            .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
            .scaleEffect(breathe ? 1.06 : 1).opacity(breathe ? 0.85 : 1)
            .accessibilityHidden(true)
    }
}
