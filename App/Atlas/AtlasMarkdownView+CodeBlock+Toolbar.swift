import SwiftUI
import AtlasCore

// Toolbar do code block — peel de AtlasMarkdownView+CodeBlock.

extension CodeBlockView {
    var codeBlockToolbar: some View {
        HStack {
            if let langLabel = MarkdownCodeBlockA11y.langLabel(lang: lang) {
                Text(langLabel)
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Spacer()
            Button(action: copyCode) {
                Text(copyButtonTitle)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(copyForeground)
            }
            .buttonStyle(.plain)
            .disabled(!canCopy)
            .accessibilityLabel(MarkdownCodeBlockA11y.spokenCopyButton(copied: copied, canCopy: canCopy))
            .accessibilityHint(MarkdownCodeBlockA11y.copyHint(canCopy: canCopy))
            .accessibilityIdentifier(A11yID.markdownCodeCopy(blockIndex))
        }
        .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 8)
    }
}
