import SwiftUI

// Code block card chrome — peel de AtlasMarkdownView+CodeBlock.

extension CodeBlockView {
    var codeBlockBackground: some View {
        RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface)
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.separator, lineWidth: 1))
    }
}
