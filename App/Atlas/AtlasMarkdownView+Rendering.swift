import SwiftUI
import AtlasCore

// Headings — peel de AtlasMarkdownView (régua anti-inchaço).
// H1 → AtlasMarkdownView+HeadingOne.swift · H2 → +HeadingTwo.swift · H3+ → +HeadingDefault.swift
// Inline/plain → AtlasMarkdownView+Inline.swift
// Table → AtlasMarkdownView+Table.swift

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
