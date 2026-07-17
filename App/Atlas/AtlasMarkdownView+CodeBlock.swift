import SwiftUI
import AtlasCore

// Code block "carved in slate" com label de linguagem + botão copiar (gap do RN).
// Copy → AtlasMarkdownView+CodeBlock+Copy.swift · Toolbar → +Toolbar.swift
struct CodeBlockView: View {
    let code: String
    let lang: String?
    var blockIndex: Int = 0

    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            codeBlockToolbar

            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.textPrimary)
                    .lineSpacing(5).textSelection(.enabled)
                    .padding(.horizontal, 16).padding(.bottom, 14)
                    .accessibilityLabel(MarkdownCodeBlockA11y.spokenBlock(lang: lang, lineCount: lineCount))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AtlasTheme.separator, lineWidth: 1))
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.markdownCodeBlock(blockIndex))
    }
}
