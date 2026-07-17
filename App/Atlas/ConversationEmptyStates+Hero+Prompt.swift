import SwiftUI
import AtlasCore

// Hero prompt — peel de ConversationEmptyStates+Hero.

extension EmptyConversation {
    var heroPromptBlock: some View {
        Text("\u{201C}\(prompt ?? "O que você quer pensar agora?")\u{201D}")
            .font(AtlasFont.serifItalic(22)).lineSpacing(10)
            .multilineTextAlignment(.center).foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityLabel(EmptyConversationA11y.spokenPrompt(prompt))
            .accessibilityAddTraits(.isHeader)
    }
}
