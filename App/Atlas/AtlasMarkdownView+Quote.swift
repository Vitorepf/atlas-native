import SwiftUI
import AtlasCore

// Quote block — peel de AtlasMarkdownView+Blocks.

extension AtlasMarkdownView {
    @ViewBuilder
    func quoteBlock(_ spans: [InlineSpan]) -> some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                .accessibilityHidden(true)
            Text(inline(spans, base: .init(font: AtlasFont.serifItalic(17), size: 17, color: AtlasTheme.textPrimary)))
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(MarkdownBlocksA11y.spokenQuote(plain(spans)))
    }
}
