import SwiftUI
import AtlasCore

// Hero prompt — peel de ConversationEmptyStates+Hero.

extension EmptyConversation {
    var heroPromptBlock: some View {
        Text(""\(prompt ?? "O que você quer pensar agora?")"")
            .font(AtlasFont.serifItalic(22)).lineSpacing(10)
            .multilineTextAlignment(.center).foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityLabel(EmptyConversationA11y.spokenPrompt(prompt))
            .accessibilityAddTraits(.isHeader)
    }
}
