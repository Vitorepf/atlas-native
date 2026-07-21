import AtlasCore
import Foundation
import SwiftUI

// Cycle 041 fuse → ConversationEmptyStates+A11y.swift

/// Sugestões são convites reais de envio; glyph ✦ é decorativo.

enum EmptyConversationA11y {
    static func spokenPrompt(_ prompt: String?) -> String {
        let text = prompt?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let text, !text.isEmpty {
            return "conversa vazia, \(text)"
        }
        return "conversa vazia, o que você quer pensar agora?"
    }

    static func spokenSuggestion(_ text: String, index: Int, total: Int) -> String {
        "sugestão \(index + 1) de \(total), \(text)"
    }

    static let suggestionHint = "envia esta pergunta agora"
}

extension EmptyConversation {
    func startBreathing() {
        if !reduceMotion {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }
}

extension EmptyConversation {
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
}

extension EmptyConversation {
    var defaultSuggestions: [String] {
        [
            "O que está rodando no Atlas agora?",
            "Resuma meu dia até aqui",
            "Qual o status dos meus projetos?",
        ]
    }
}

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
