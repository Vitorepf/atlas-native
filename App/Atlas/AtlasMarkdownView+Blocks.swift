import SwiftUI
import AtlasCore

// List blocks — peel de AtlasMarkdownView.
// Quote → AtlasMarkdownView+Quote.swift
// Marker → AtlasMarkdownView+ListMarker.swift

extension AtlasMarkdownView {
    @ViewBuilder
    func listBlock(ordered: Bool, items: [[InlineSpan]]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                HStack(alignment: .top, spacing: 0) {
                    listItemMarker(ordered: ordered, index: idx)
                    Text(inline(item, base: .init(font: .system(size: 16), size: 16, color: AtlasTheme.textPrimary)))
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(MarkdownBlocksA11y.spokenListItem(ordered: ordered, index: idx, plain: plain(item)))
            }
        }
    }
}
