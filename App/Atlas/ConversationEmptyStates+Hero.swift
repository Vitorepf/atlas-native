import AtlasCore
import SwiftUI

// Cycle 040 fuse → ConversationEmptyStates+Hero.swift

extension EmptyConversation {
    var heroGlyph: some View {
        Text("✦")
            .font(AtlasFont.serif(32)).foregroundStyle(AtlasTheme.accent)
            .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
            .scaleEffect(breathe ? 1.06 : 1).opacity(breathe ? 0.85 : 1)
            .accessibilityHidden(true)
    }
}

extension EmptyConversation {
    var heroPromptBlock: some View {
        Text("\u{201C}\(prompt ?? "O que você quer pensar agora?")\u{201D}")
            .font(AtlasFont.serifItalic(22)).lineSpacing(10)
            .multilineTextAlignment(.center).foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityLabel(EmptyConversationA11y.spokenPrompt(prompt))
            .accessibilityAddTraits(.isHeader)
    }
}

extension EmptyConversation {
    var heroStack: some View {
        VStack(spacing: 0) {
            heroGlyph
            Spacer().frame(height: 40)
            heroPromptBlock
            Spacer().frame(height: 44)
            suggestionStack
        }
    }
}
