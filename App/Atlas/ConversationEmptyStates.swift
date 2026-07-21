import AtlasCore
import Foundation
import SwiftUI

// Cycle 044 fuse → ConversationEmptyStates.swift

struct EmptyConversation: View {
    let reduceMotion: Bool
    /// Assunto da conversa. Ausente = a conversa do Atlas, que é sobre tudo.
    var prompt: String? = nil
    var suggestionsOverride: [String]? = nil
    let onSuggestion: (String) -> Void
    @State var breathe = false

    var body: some View {
        heroStack
            .padding(.horizontal, 32).padding(.top, 56)
            .frame(maxWidth: .infinity)
            .onAppear { startBreathing() }
            .accessibilityElement(children: .contain)
    }
}

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

extension EmptyConversation {
    var heroGlyph: some View {
        Text("✦")
            .font(AtlasFont.serif(32)).foregroundStyle(AtlasTheme.accent)
            .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
            .scaleEffect(breathe ? 1.06 : 1).opacity(breathe ? 0.85 : 1)
            .accessibilityHidden(true)
    }
}

extension EmptyConversation {
    var heroPromptBlock: some View {
        Text("\u{201C}\(prompt ?? "O que você quer pensar agora?")\u{201D}")
            .font(AtlasFont.serifItalic(22)).lineSpacing(10)
            .multilineTextAlignment(.center).foregroundStyle(AtlasTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(EmptyConversationA11y.spokenPrompt(prompt))
            .accessibilityAddTraits(.isHeader)
    }
}

extension EmptyConversation {
    var heroStack: some View {
        VStack(spacing: 0) {
            heroGlyph
            Spacer().frame(height: 36)
            heroPromptBlock
            Spacer().frame(height: 40)
            suggestionStack
        }
    }
}

extension EmptyConversation {
    func suggestionButton(_ s: String, index: Int) -> some View {
        Button {
            // Medium: suggestion is a real send (same class as composer).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onSuggestion(s)
        } label: {
            Text(s)
                .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18).padding(.vertical, 12)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    Capsule().fill(AtlasTheme.surface)
                        .overlay(
                            Capsule().strokeBorder(
                                LinearGradient(
                                    colors: [
                                        AtlasTheme.accent.opacity(0.12),
                                        AtlasTheme.separator
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                        )
                )
        }
        .buttonStyle(PressableScale())
        // Identifier = texto da sugestão (UITests + Voice Control estáveis).
        // Label falada leva o contexto "sugestão N de M".
        .accessibilityIdentifier(s)
        .accessibilityLabel(
            EmptyConversationA11y.spokenSuggestion(s, index: index, total: suggestions.count)
        )
        .accessibilityHint(EmptyConversationA11y.suggestionHint)
    }
}
