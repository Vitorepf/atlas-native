import SwiftUI
import AtlasCore

// Suggestion button — peel de ConversationEmptyStates+Suggestions.

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
        .accessibilityLabel(
            EmptyConversationA11y.spokenSuggestion(s, index: index, total: suggestions.count)
        )
        .accessibilityHint(EmptyConversationA11y.suggestionHint)
    }
}
