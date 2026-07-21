import AtlasCore
import SwiftUI

// Cycle 041 fuse → AtlasMarkdownView.swift

extension AtlasMarkdownView {
    func refreshBlocks(force: Bool) {
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
}

extension AtlasMarkdownView {
    /// Fronteira barata: parágrafo novo ou fence fechando — re-parse imediato.
    static func isBlockBoundary(_ text: String) -> Bool {
        text.hasSuffix("\n\n") || text.hasSuffix("```\n") || text.hasSuffix("```")
    }
}

extension AtlasMarkdownView {
    func parseRefreshLifecycle<Content: View>(_ content: Content) -> some View {
        content
            .onAppear { refreshBlocks(force: true) }
            .onChange(of: text) { _, _ in refreshBlocks(force: !streaming) }
            .onChange(of: streaming) { _, isStreaming in
                if !isStreaming { refreshBlocks(force: true) }
            }
    }
}

extension AtlasMarkdownView {
    struct InlineBase {
        let font: Font
        let size: CGFloat
        let color: Color
        // Serif/mono escalam sozinhos (relativeTo); o sans dos marks precisa
        // da categoria para escalar junto.
        var typeSize: DynamicTypeSize = .large
    }

    @ViewBuilder
    func heading(_ level: Int, _ spans: [InlineSpan]) -> some View {
        switch level {
        case 1: headingOne(spans)
        case 2: headingTwo(spans)
        default: headingDefault(spans)
        }
    }
}

// Renderiza markdown na tipografia do Atlas — porte de EditorialMarkdown.tsx.
struct AtlasMarkdownView: View {
    let text: String
    var streaming: Bool = false

    // O corpo da resposta escala com o ajuste de texto do operador; os marks
    // derivados (bold/link) seguem pela InlineBase.typeSize.
    @Environment(\.dynamicTypeSize) var typeSize

    @State var blocks: [MarkdownBlock] = []
    @State var cachedCount: Int = -1
    @State var lastParseAt: CFAbsoluteTime = 0

    var body: some View {
        parseRefreshLifecycle(
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                    blockView(block, index: index)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        )
    }
}
