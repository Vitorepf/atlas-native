import SwiftUI
import AtlasCore

// Empty state vivo + falha de carga da thread — peel de EditorialTurn.

// Empty state vivo: a pergunta contemplativa ✦ + convites REAIS (cada chip
// dispara um envio de verdade — nada decorativo).
struct EmptyConversation: View {
    let reduceMotion: Bool
    /// Assunto da conversa. Ausente = a conversa do Atlas, que é sobre tudo.
    var prompt: String? = nil
    var suggestionsOverride: [String]? = nil
    let onSuggestion: (String) -> Void
    @State private var breathe = false

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

    private var suggestions: [String] {
        suggestionsOverride ?? [
            "O que está rodando no Atlas agora?",
            "Resuma meu dia até aqui",
            "Qual o status dos meus projetos?",
        ]
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
        .padding(.horizontal, 32).padding(.top, 120)
        .frame(maxWidth: .infinity)
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    breathe = true
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}
