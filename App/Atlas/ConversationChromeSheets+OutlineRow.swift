import SwiftUI
import AtlasCore

// Outline row — peel de ConversationChromeSheets+Outline.
// Lead → ConversationChromeSheets+OutlineLead.swift

struct ConversationOutlineRow: View {
    let index: Int
    let bubble: ChatBubble
    var reduceMotion: Bool = false

    var body: some View {
        outlineLead
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 10)
            .accessibilityIdentifier(A11yID.conversationOutlineRow(index))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                ConversationOutlineA11y.spokenRow(index: index, role: bubble.role, snippet: snippet)
            )
    }
}
