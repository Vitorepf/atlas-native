import SwiftUI
import AtlasCore

// Code/divider/table branches — peel de AtlasMarkdownView+BlockViewStructural.
// Code → AtlasMarkdownView+BlockViewStructural+CodeTable+Code.swift

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructuralCodeTable(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .code:
            blockViewStructuralCode(block, index: index)
        case .divider:
            blockViewDividerBlock
        case .table:
            blockViewTableBlock(block)
        default:
            EmptyView()
        }
    }
}
