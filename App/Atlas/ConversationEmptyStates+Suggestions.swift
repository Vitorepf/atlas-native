import SwiftUI
import AtlasCore

// Sugestões — peel de EmptyConversation.
// Breathe → ConversationEmptyStates+Breathe.swift
// Button → ConversationEmptyStates+SuggestionButton.swift

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
                suggestionButton(s, index: index)
            }
        }
        .padding(.horizontal, 12)
    }
}
