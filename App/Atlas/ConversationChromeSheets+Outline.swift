import SwiftUI
import AtlasCore

// MARK: - Índice da conversa
// Row → ConversationChromeSheets+OutlineRow.swift

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
