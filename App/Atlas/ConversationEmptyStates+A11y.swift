import Foundation

/// Spoken labels do empty conversation — peel de ConversationEmptyStates (CICLO C).
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
