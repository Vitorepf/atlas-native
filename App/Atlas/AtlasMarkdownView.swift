import SwiftUI
import AtlasCore

// Renderiza markdown na tipografia do Atlas — porte de EditorialMarkdown.tsx.
// Parse → AtlasMarkdownView+Parse.swift · Rendering → +Rendering · Code → +CodeBlock
// Block → AtlasMarkdownView+BlockView.swift · Refresh → +ParseRefresh.swift
struct AtlasMarkdownView: View {
    let text: String
    var streaming: Bool = false

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
