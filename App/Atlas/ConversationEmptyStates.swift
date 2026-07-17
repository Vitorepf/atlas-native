import SwiftUI
import AtlasCore

// Empty state vivo + falha de carga da thread — peel de EditorialTurn.
// Suggestions → ConversationEmptyStates+Suggestions.swift
// Hero → ConversationEmptyStates+Hero.swift

struct EmptyConversation: View {
    let reduceMotion: Bool
    /// Assunto da conversa. Ausente = a conversa do Atlas, que é sobre tudo.
    var prompt: String? = nil
    var suggestionsOverride: [String]? = nil
    let onSuggestion: (String) -> Void
    @State var breathe = false

    init(
        reduceMotion: Bool,
        prompt: String? = nil,
        suggestions: [String]? = nil,
        onSuggestion: @escaping (String) -> Void
    ) {
        self.reduceMotion = reduceMotion
        self.prompt = prompt
        self.suggestionsOverride = suggestions
        self.onSuggestion = onSuggestion
    }

    var body: some View {
        heroStack
            .padding(.horizontal, 32).padding(.top, 120)
            .frame(maxWidth: .infinity)
            .onAppear { startBreathing() }
            .accessibilityElement(children: .contain)
    }
}
