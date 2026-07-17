import SwiftUI
import AtlasCore

// Toolbar do code block — peel de AtlasMarkdownView+CodeBlock.
// Copy → AtlasMarkdownView+CodeBlock+ToolbarCopy.swift

extension CodeBlockView {
    var codeBlockToolbar: some View {
        HStack {
            if let langLabel = MarkdownCodeBlockA11y.langLabel(lang: lang) {
                Text(langLabel)
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Spacer()
            codeBlockCopyButton
        }
        .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 8)
    }
}
