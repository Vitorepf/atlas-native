import SwiftUI
import AtlasCore

// Code block "carved in slate" com label de linguagem + botão copiar (gap do RN).
// Copy → AtlasMarkdownView+CodeBlock+Copy.swift · Toolbar → +Toolbar.swift
// Scroll → AtlasMarkdownView+CodeBlockScroll.swift · Background → +Background.swift

struct CodeBlockView: View {
    let code: String
    let lang: String?
    var blockIndex: Int = 0

    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            codeBlockToolbar
            codeBlockScroll
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(codeBlockBackground)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.markdownCodeBlock(blockIndex))
    }
}
