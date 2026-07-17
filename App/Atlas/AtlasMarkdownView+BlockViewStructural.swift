import SwiftUI
import AtlasCore

// Structural blocks — peel de AtlasMarkdownView+BlockViewBody.

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructural(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
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
        default:
            EmptyView()
        }
    }
}
