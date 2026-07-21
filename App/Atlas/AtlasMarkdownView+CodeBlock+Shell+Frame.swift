import SwiftUI
import AtlasCore

// Code block frame — peel de AtlasMarkdownView+CodeBlock+Shell.

extension CodeBlockView {
    @ViewBuilder
    var codeBlockShellFrame: some View {
        codeBlockShellStack
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(codeBlockBackground)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.markdownCodeBlock(blockIndex))
    }
}
