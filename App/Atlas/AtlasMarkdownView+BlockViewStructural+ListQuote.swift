import SwiftUI
import AtlasCore

// List/quote branches — peel de AtlasMarkdownView+BlockViewStructural.

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructuralListQuote(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .list:
            blockViewListBlock(block)
        case .quote:
            blockViewQuoteBlock(block)
        default:
            EmptyView()
        }
    }
}
