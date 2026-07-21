import SwiftUI
import AtlasCore

// List blocks — peel de AtlasMarkdownView.
// Item → AtlasMarkdownView+Blocks+ListItem.swift

extension AtlasMarkdownView {
    @ViewBuilder
    func listBlock(ordered: Bool, items: [[InlineSpan]]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                listBlockItem(ordered: ordered, index: idx, item: item)
            }
        }
    }
}
