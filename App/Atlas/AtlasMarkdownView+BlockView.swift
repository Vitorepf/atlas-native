import SwiftUI
import AtlasCore

// Switch de blocos — peel de AtlasMarkdownView.

extension AtlasMarkdownView {
    @ViewBuilder
    func blockView(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .paragraph(let spans):
            Text(inline(spans, base: .init(font: .system(size: 16), size: 16, color: AtlasTheme.textPrimary)))
                .lineSpacing(6)

        case .heading(let level, let spans):
            heading(level, spans)

        case .list(let ordered, let items):
            listBlock(ordered: ordered, items: items)

        case .quote(let spans):
            quoteBlock(spans)

        case .code(let codeText, let lang):
            CodeBlockView(code: codeText, lang: lang, blockIndex: index)

        case .divider:
            Rectangle().fill(AtlasTheme.separator).frame(height: 1).padding(.vertical, 2)

        case .table(let headers, let rows):
            tableView(headers, rows)
        }
    }
}
