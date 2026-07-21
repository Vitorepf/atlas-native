import SwiftUI
import AtlasCore

// WAVE-017 markdown host

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

