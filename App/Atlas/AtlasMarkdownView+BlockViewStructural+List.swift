import SwiftUI
import AtlasCore

// List block — peel de AtlasMarkdownView+BlockViewStructural.

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewListBlock(_ block: MarkdownBlock) -> some View {
        if case .list(let ordered, let items) = block {
            listBlock(ordered: ordered, items: items)
        }
    }
}
