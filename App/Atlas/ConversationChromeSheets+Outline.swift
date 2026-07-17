import SwiftUI
import AtlasCore

// MARK: - Índice da conversa

struct ConversationOutlineSheet: View {
    let bubbles: [ChatBubble]
    var reduceMotion: Bool = false

    var body: some View {
        SheetShell(title: "Índice da conversa") {
            ForEach(Array(bubbles.enumerated()), id: \.element.id) { index, bubble in
                ConversationOutlineRow(index: index + 1, bubble: bubble, reduceMotion: reduceMotion)
            }
        }
    }
}

struct ConversationOutlineRow: View {
    let index: Int
    let bubble: ChatBubble
    var reduceMotion: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(String(format: "%02d", index))
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
            VStack(alignment: .leading, spacing: 3) {
                Text(bubble.role == "user" ? "Você" : "Atlas")
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(snippet)
                    .font(.system(.footnote))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, 10)
        .accessibilityIdentifier(A11yID.conversationOutlineRow(index))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("turno \(index), \(bubble.role == "user" ? "você" : "Atlas"), \(snippet)")
    }

    private var snippet: String {
        let text = AtlasMarkdown.plainText(bubble.text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? "sem texto visível" : String(text.prefix(140))
    }
}
