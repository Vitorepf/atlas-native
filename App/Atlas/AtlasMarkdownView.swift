import SwiftUI
import AtlasCore

// Renderiza markdown na tipografia do Atlas — porte de EditorialMarkdown.tsx.
// Parse → AtlasMarkdownView+Parse.swift · Rendering → +Rendering · Code → +CodeBlock
struct AtlasMarkdownView: View {
    let text: String
    var streaming: Bool = false

    @State var blocks: [MarkdownBlock] = []
    @State var cachedCount: Int = -1
    @State var lastParseAt: CFAbsoluteTime = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                blockView(block, index: index)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { refreshBlocks(force: true) }
        .onChange(of: text) { _, _ in refreshBlocks(force: !streaming) }
        .onChange(of: streaming) { _, isStreaming in
            if !isStreaming { refreshBlocks(force: true) }
        }
    }

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
