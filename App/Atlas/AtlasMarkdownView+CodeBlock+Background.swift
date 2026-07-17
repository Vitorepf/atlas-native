import SwiftUI

// Code block card chrome — peel de AtlasMarkdownView+CodeBlock.

extension CodeBlockView {
    var codeBlockBackground: some View {
        RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AtlasTheme.separator, lineWidth: 1))
    }
}
