import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: was ConversationEmptyStates — EmptyConversation chrome
// Load fail: ConversationMessages → AtlasNetworkFailureEmpty

// MARK: - Host

struct EmptyConversation: View {
    let reduceMotion: Bool
    /// Assunto da conversa. Ausente = quote default via Judgment.
    var prompt: String? = nil
    var suggestionsOverride: [String]? = nil
    /// Home partida only — unlocks default catalog when suggestions nil.
    var isHomePartida: Bool = false
    var hasWorkspaces: Bool = false
    let onSuggestion: (String) -> Void
    @State private var breathe = false

    init(
        reduceMotion: Bool,
        prompt: String? = nil,
        suggestions: [String]? = nil,
        isHomePartida: Bool = false,
        hasWorkspaces: Bool = false,
        onSuggestion: @escaping (String) -> Void
    ) {
        self.reduceMotion = reduceMotion
        self.prompt = prompt
        self.suggestionsOverride = suggestions
        self.isHomePartida = isHomePartida
        self.hasWorkspaces = hasWorkspaces
        self.onSuggestion = onSuggestion
    }

    private var face: ConversationEmptyFace {
        ConversationEmptyJudgment.face(
            prompt: prompt,
            suggestions: suggestionsOverride,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
    }

    private var displayPrompt: String {
        ConversationEmptyJudgment.resolvedPrompt(prompt)
    }

    private var suggestions: [String] {
        ConversationEmptyJudgment.resolvedSuggestions(
            suggestions: suggestionsOverride,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(32)).foregroundStyle(AtlasTheme.accent)
                .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
                .scaleEffect(breathe ? 1.06 : 1).opacity(breathe ? 0.85 : 1)
                .accessibilityHidden(true)
            Spacer().frame(height: 40)
            Text("\u{201C}\(displayPrompt)\u{201D}")
                .font(AtlasFont.serifItalic(22)).lineSpacing(10)
                .multilineTextAlignment(.center).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityLabel(ConversationEmptyJudgment.spokenPrompt(prompt))
                .accessibilityAddTraits(.isHeader)
                .accessibilityValue(face.productWord)
            Spacer().frame(height: 44)
            if !suggestions.isEmpty {
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
                        .accessibilityIdentifier(s)
                        .accessibilityLabel(
                            ConversationEmptyJudgment.spokenSuggestion(
                                s, index: index, total: suggestions.count
                            )
                        )
                        .accessibilityHint(ConversationEmptyJudgment.suggestionHint)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .padding(.horizontal, 32).padding(.top, 56)
        .frame(maxWidth: .infinity)
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    breathe = true
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("conversation.empty.\(face.productWord)")
    }
}
