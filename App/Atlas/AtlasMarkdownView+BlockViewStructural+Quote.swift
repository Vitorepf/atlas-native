import SwiftUI
import AtlasCore

// Quote block — peel de AtlasMarkdownView+BlockViewStructural.

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewQuoteBlock(_ block: MarkdownBlock) -> some View {
        if case .quote(let spans) = block {
            quoteBlock(spans)
        }
    }
}
