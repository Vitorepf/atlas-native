import SwiftUI
import AtlasCore

// Markdown + signature + feedback — peel de EditorialTurn+Closing.
// Meta → EditorialTurn+ClosingMeta.swift

extension EditorialTurn {
    @ViewBuilder
    var assistantClosingTail: some View {
        if !bubble.text.isEmpty {
            AtlasMarkdownView(text: bubble.text, streaming: bubble.streaming)
        }
        assistantClosingMeta
    }
}
