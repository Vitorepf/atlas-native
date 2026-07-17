import SwiftUI
import AtlasCore

// Structural blocks — peel de AtlasMarkdownView+BlockViewBody.
// ListQuote → AtlasMarkdownView+BlockViewStructural+ListQuote.swift
// CodeTable → AtlasMarkdownView+BlockViewStructural+CodeTable.swift

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructural(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .list, .quote:
            blockViewStructuralListQuote(block, index: index)
        case .code, .divider, .table:
            blockViewStructuralCodeTable(block, index: index)
        default:
            EmptyView()
        }
    }
}
