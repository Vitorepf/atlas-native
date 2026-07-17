import SwiftUI
import AtlasCore

// Hero glyph + prompt — peel de EmptyConversation.

extension EmptyConversation {
    var heroStack: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(32)).foregroundStyle(AtlasTheme.accent)
                .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
                .scaleEffect(breathe ? 1.06 : 1).opacity(breathe ? 0.85 : 1)
                .accessibilityHidden(true)
            Spacer().frame(height: 40)
            Text(""\(prompt ?? "O que você quer pensar agora?")"")
                .font(AtlasFont.serifItalic(22)).lineSpacing(10)
                .multilineTextAlignment(.center).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityLabel(EmptyConversationA11y.spokenPrompt(prompt))
                .accessibilityAddTraits(.isHeader)
            Spacer().frame(height: 44)
            suggestionStack
        }
    }
}
