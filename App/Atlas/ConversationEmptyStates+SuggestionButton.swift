import AtlasCore
import SwiftUI

// Cycle 040 fuse → ConversationEmptyStates+SuggestionButton.swift

extension EmptyConversation {
    func suggestionButton(_ s: String, index: Int) -> some View {
        Button { onSuggestion(s) } label: {
            Text(s)
                .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textSecondary)
                .padding(.horizontal, 18).padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Capsule().fill(AtlasTheme.surface)
                    .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
        }
        .buttonStyle(PressableScale())
        // Identifier = texto da sugestão (UITests + Voice Control estáveis).
        // Label falada leva o contexto "sugestão N de M".
        .accessibilityIdentifier(s)
        .accessibilityLabel(
            EmptyConversationA11y.spokenSuggestion(s, index: index, total: suggestions.count)
        )
        .accessibilityHint(EmptyConversationA11y.suggestionHint)
    }
}
