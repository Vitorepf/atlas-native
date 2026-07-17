import SwiftUI
import AtlasCore

// Sugestões — peel de EmptyConversation.
// Breathe → ConversationEmptyStates+Breathe.swift

extension EmptyConversation {
    var suggestions: [String] {
        suggestionsOverride ?? [
            "O que está rodando no Atlas agora?",
            "Resuma meu dia até aqui",
            "Qual o status dos meus projetos?",
        ]
    }

    var suggestionStack: some View {
        VStack(spacing: 10) {
            ForEach(Array(suggestions.enumerated()), id: \.element) { index, s in
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
        .padding(.horizontal, 12)
    }
}
