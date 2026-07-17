import SwiftUI
import AtlasCore

// Empty state vivo + falha de carga da thread — peel de EditorialTurn.
// Suggestions → ConversationEmptyStates+Suggestions.swift

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
        .padding(.horizontal, 32).padding(.top, 120)
        .frame(maxWidth: .infinity)
        .onAppear { startBreathing() }
        .accessibilityElement(children: .contain)
    }
}
