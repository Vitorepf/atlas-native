import SwiftUI
import AtlasCore

// Renderiza markdown na tipografia do Atlas — porte de EditorialMarkdown.tsx.
// Regra de ouro: *italic* é SEMPRE Fraunces italic (oralidade); **bold** é Sans
// semibold (peso editorial); `code` é JetBrains Mono em surface (registro).
// Tom "operational" (padrão das respostas): corpo em Sans; headings escalonados.
//
// Streaming (F2.7): enquanto `streaming`, memoiza o parse por contagem de chars
// com throttle ~100ms (ou fronteira de bloco `\n\n` / fence). No finalize,
// parse completo único — evita O(n²) re-parse a cada token.
// Rendering → AtlasMarkdownView+Rendering.swift; code blocks → +CodeBlock.swift.
struct AtlasMarkdownView: View {
    let text: String
    var streaming: Bool = false

    @State private var blocks: [MarkdownBlock] = []
    @State private var cachedCount: Int = -1
    @State private var lastParseAt: CFAbsoluteTime = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                blockView(block)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { refreshBlocks(force: true) }
        .onChange(of: text) { _, _ in refreshBlocks(force: !streaming) }
        .onChange(of: streaming) { _, isStreaming in
            if !isStreaming { refreshBlocks(force: true) }
        }
    }

    private func refreshBlocks(force: Bool) {
        let count = text.count
        if count == cachedCount, !force { return }

        if !force, streaming {
            let now = CFAbsoluteTimeGetCurrent()
            let elapsed = now - lastParseAt
            if elapsed < 0.1, !Self.isBlockBoundary(text) { return }
            lastParseAt = now
        } else {
            lastParseAt = CFAbsoluteTimeGetCurrent()
        }

        cachedCount = count
        blocks = AtlasMarkdown.parse(text)
    }

    /// Fronteira barata: parágrafo novo ou fence fechando — re-parse imediato.
    private static func isBlockBoundary(_ text: String) -> Bool {
        text.hasSuffix("\n\n") || text.hasSuffix("```\n") || text.hasSuffix("```")
    }

    @ViewBuilder
    func blockView(_ block: MarkdownBlock) -> some View {
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
            CodeBlockView(code: codeText, lang: lang)

        case .divider:
            Rectangle().fill(AtlasTheme.separator).frame(height: 1).padding(.vertical, 2)

        case .table(let headers, let rows):
            tableView(headers, rows)
        }
    }
}
