import SwiftUI
import AtlasCore

// WAVE-017 markdown

// MARK: - Block dispatch

extension AtlasMarkdownView {
    @ViewBuilder
    func blockView(_ block: MarkdownBlock, index: Int) -> some View {
        blockViewBody(block, index: index)
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewBody(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .paragraph, .heading:
            blockViewInline(block)
        case .list, .quote, .code, .divider, .table:
            blockViewStructural(block, index: index)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewInline(_ block: MarkdownBlock) -> some View {
        switch block {
        case .paragraph(let spans):
            Text(inline(spans, base: .init(font: AtlasFont.sans(16, weight: .regular, at: typeSize), size: 16, color: AtlasTheme.textPrimary, typeSize: typeSize)))
                .lineSpacing(6)
        case .heading(let level, let spans):
            heading(level, spans)
        default:
            EmptyView()
        }
    }
}
