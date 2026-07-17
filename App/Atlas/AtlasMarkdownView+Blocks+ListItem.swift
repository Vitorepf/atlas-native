import SwiftUI
import AtlasCore

// List item row — peel de AtlasMarkdownView+Blocks.

extension AtlasMarkdownView {
    @ViewBuilder
    func listBlockItem(ordered: Bool, index: Int, item: [InlineSpan]) -> some View {
        HStack(alignment: .top, spacing: 0) {
            listItemMarker(ordered: ordered, index: index)
            Text(inline(item, base: .init(font: .system(size: 16), size: 16, color: AtlasTheme.textPrimary)))
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(MarkdownBlocksA11y.spokenListItem(ordered: ordered, index: index, plain: plain(item)))
    }
}
