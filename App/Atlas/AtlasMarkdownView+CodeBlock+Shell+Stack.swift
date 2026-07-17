import SwiftUI
import AtlasCore

// Code block stack — peel de AtlasMarkdownView+CodeBlock+Shell.

extension CodeBlockView {
    @ViewBuilder
    var codeBlockShellStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            codeBlockToolbar
            codeBlockScroll
        }
    }
}
