import SwiftUI
import AtlasCore

// Structural blocks — peel de AtlasMarkdownView+BlockViewBody.
// List → AtlasMarkdownView+BlockViewStructural+List.swift
// Quote → AtlasMarkdownView+BlockViewStructural+Quote.swift
// Code → AtlasMarkdownView+BlockViewStructural+Code.swift
// Divider → AtlasMarkdownView+BlockViewStructural+Divider.swift
// Table → AtlasMarkdownView+BlockViewStructural+Table.swift

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructural(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .list:
            blockViewListBlock(block)
        case .quote:
            blockViewQuoteBlock(block)
        case .code:
            blockViewCodeBlock(block, index: index)
        case .divider:
            blockViewDividerBlock
        case .table:
            blockViewTableBlock(block)
        default:
            EmptyView()
        }
    }
}
