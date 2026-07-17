import SwiftUI
import AtlasCore

// Outline row — peel de ConversationChromeSheets+Outline.

struct ConversationOutlineRow: View {
    let index: Int
    let bubble: ChatBubble
    var reduceMotion: Bool = false

    var snippet: String {
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
