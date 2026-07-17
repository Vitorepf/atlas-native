import SwiftUI
import AtlasCore

// MARK: - Índice da conversa
// Row → ConversationChromeSheets+OutlineRow.swift
// Empty → ConversationChromeSheets+OutlineEmpty.swift

struct ConversationOutlineSheet: View {
    let bubbles: [ChatBubble]
    var reduceMotion: Bool = false

    var body: some View {
        SheetShell(title: "Índice da conversa") {
            if bubbles.isEmpty {
                outlineEmpty
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
