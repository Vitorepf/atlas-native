import SwiftUI
import AtlasCore

// Code block shell — peel de AtlasMarkdownView+CodeBlock.

extension CodeBlockView {
    var codeBlockShell: some View {
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
