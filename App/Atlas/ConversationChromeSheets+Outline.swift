import SwiftUI
import AtlasCore

// MARK: - Índice da conversa
// Row → ConversationChromeSheets+OutlineRow.swift
// Empty → ConversationChromeSheets+OutlineEmpty.swift

struct ConversationOutlineSheet: View {
    let bubbles: [ChatBubble]
    var reduceMotion: Bool = false

    var body: some View {
        outlineA11yBind(
            SheetShell(title: "Índice da conversa") {
                if bubbles.isEmpty {
                    outlineEmpty
                } else {
                    outlineRowList
                }
            }
        )
    }
}
