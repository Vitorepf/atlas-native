import SwiftUI
import AtlasCore

// WAVE-172 density peel — markdown code blocks

// MARK: - Code blocks

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewCodeBlock(_ block: MarkdownBlock, index: Int) -> some View {
        if case .code(let codeText, let lang) = block {
            CodeBlockView(code: codeText, lang: lang, blockIndex: index)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructuralCode(_ block: MarkdownBlock, index: Int) -> some View {
        if case .code = block {
            blockViewCodeBlock(block, index: index)
        }
    }
}

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

extension AtlasMarkdownView {
    @ViewBuilder
    var blockViewDividerBlock: some View {
        Rectangle().fill(AtlasTheme.separator).frame(height: 1).padding(.vertical, 2)
    }
}
