import SwiftUI
import AtlasCore

// MARK: - Índice da conversa

struct ConversationOutlineSheet: View {
    let bubbles: [ChatBubble]
    var reduceMotion: Bool = false

    var body: some View {
        SheetShell(title: "Índice da conversa") {
            if bubbles.isEmpty {
                Text("Nenhum turno carregado nesta thread.")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.vertical, 12)
                    .accessibilityLabel(ConversationOutlineA11y.spokenEmptySheet())
                    .accessibilityAddTraits(.isStaticText)
            } else {
                ForEach(Array(bubbles.enumerated()), id: \.element.id) { index, bubble in
                    ConversationOutlineRow(index: index + 1, bubble: bubble, reduceMotion: reduceMotion)
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 6)))
                }
            }
        }
        .accessibilityIdentifier(A11yID.conversationOutlineSheet)
        .accessibilityLabel(ConversationOutlineA11y.spokenSheetLabel(turnCount: bubbles.count))
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: bubbles.map(\.id))
    }
}

struct ConversationOutlineRow: View {
    let index: Int
    let bubble: ChatBubble
    var reduceMotion: Bool = false

    private var snippet: String {
        ConversationOutlineA11y.spokenSnippet(from: bubble.text)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(String(format: "%02d", index))
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(bubble.role == "user" ? "Você" : "Atlas")
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Text(snippet)
                    .font(.system(.footnote))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, 10)
        .accessibilityIdentifier(A11yID.conversationOutlineRow(index))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            ConversationOutlineA11y.spokenRow(index: index, role: bubble.role, snippet: snippet)
        )
    }
}
