import SwiftUI
import AtlasCore

// Sugestões — peel de EmptyConversation.
// Breathe → ConversationEmptyStates+Breathe.swift
// Button → ConversationEmptyStates+SuggestionButton.swift
// Defaults → ConversationEmptyStates+SuggestionDefaults.swift

extension EmptyConversation {
    var suggestions: [String] {
        suggestionsOverride ?? defaultSuggestions
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
