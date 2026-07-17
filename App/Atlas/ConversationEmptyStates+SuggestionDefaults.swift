import SwiftUI
import AtlasCore

// Default suggestion copy — peel de ConversationEmptyStates+Suggestions.

extension EmptyConversation {
    var defaultSuggestions: [String] {
        [
            "O que está rodando no Atlas agora?",
            "Resuma meu dia até aqui",
            "Qual o status dos meus projetos?",
        ]
    }
}
