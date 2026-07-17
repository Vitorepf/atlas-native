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
            Spacer().frame(height: 40)
            Text(""\(prompt ?? "O que você quer pensar agora?")"")
                .font(AtlasFont.serifItalic(22)).lineSpacing(10)
                .multilineTextAlignment(.center).foregroundStyle(AtlasTheme.textPrimary)
            Spacer().frame(height: 44)
            VStack(spacing: 10) {
                ForEach(suggestions, id: \.self) { s in
                    Button { onSuggestion(s) } label: {
                        Text(s)
                            .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textSecondary)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Capsule().fill(AtlasTheme.surface)
                                .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
                    }
                    .buttonStyle(PressableScale())
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.horizontal, 32).padding(.top, 120)
        .frame(maxWidth: .infinity)
        .onAppear { if !reduceMotion { withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { breathe = true } } }
    }
}

/// Load da thread falhou sem cache: mesma voz da home (`AtlasFailureCopy` + kind).
struct ConversationLoadFailure: View {
    let kind: AtlasNetworkFailureKind?
    let hasToken: Bool
    let host: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(28)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
            Spacer().frame(height: 28)
            Text(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken))
                .font(AtlasFont.serif(22, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
            Spacer().frame(height: 12)
            Text(hasToken ? "\(host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
            Spacer().frame(height: 16)
            Text(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))
                .font(.system(.subheadline)).lineSpacing(5)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
            if hasToken {
                Spacer().frame(height: 28)
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    onRetry()
                } label: {
                    Text("Tentar de novo")
                        .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.accent)
                        .padding(.horizontal, 22).padding(.vertical, 10)
                        .background(Capsule().fill(AtlasTheme.goldVeil)
                            .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                }
                .buttonStyle(PressableScale())
                .accessibilityHint("reconecta e recarrega esta conversa")
            }
        }
        .padding(.horizontal, 44).padding(.top, 100)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)). \(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))")
        .accessibilityIdentifier(A11yID.conversationLoadFailure)
    }
}
