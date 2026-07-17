import SwiftUI
import AtlasCore

// Code block structural — peel de AtlasMarkdownView+BlockViewStructural+CodeTable.

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructuralCode(_ block: MarkdownBlock, index: Int) -> some View {
        if case .code = block {
            blockViewCodeBlock(block, index: index)
        }
    }
}
