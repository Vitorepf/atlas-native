import SwiftUI
import AtlasCore

// WAVE-172 density peel — markdown lists/quotes/tables

// MARK: - Lists / quotes / tables

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewListBlock(_ block: MarkdownBlock) -> some View {
        if case .list(let ordered, let items) = block {
            listBlock(ordered: ordered, items: items)
        }
    }
}

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

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewQuoteBlock(_ block: MarkdownBlock) -> some View {
        if case .quote(let spans) = block {
            quoteBlock(spans)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewTableBlock(_ block: MarkdownBlock) -> some View {
        if case .table(let headers, let rows) = block {
            tableView(headers, rows)
        }
    }
}

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

extension AtlasMarkdownView {
    @ViewBuilder
    func listBlockItem(ordered: Bool, index: Int, item: [InlineSpan]) -> some View {
        HStack(alignment: .top, spacing: 0) {
            listItemMarker(ordered: ordered, index: index)
            Text(inline(item, base: .init(font: AtlasFont.sans(16, weight: .regular, at: typeSize), size: 16, color: AtlasTheme.textPrimary, typeSize: typeSize)))
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AtlasMarkdownJudgment.spokenListItem(ordered: ordered, index: index, plain: plain(item)))
    }
}

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
