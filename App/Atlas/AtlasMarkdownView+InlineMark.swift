import SwiftUI
import AtlasCore

// Inline mark styles — peel de AtlasMarkdownView+Inline.
// Code/link → AtlasMarkdownView+InlineMarkDecorated.swift

extension AtlasMarkdownView {
    func inlineMark(_ span: InlineSpan, base: InlineBase) -> AttributedString {
        if let decorated = inlineDecoratedMark(span, base: base) {
            return decorated
        }
        switch span {
        case .text(let t):
            var piece = AttributedString(t)
            piece.font = base.font
            piece.foregroundColor = base.color
            return piece
        case .bold(let t):
            var piece = AttributedString(t)
            piece.font = .system(size: base.size, weight: .semibold)
            piece.foregroundColor = AtlasTheme.textPrimary
            return piece
        case .italic(let t):
            var piece = AttributedString(t)
            piece.font = AtlasFont.serifItalic(base.size)
            piece.foregroundColor = base.color
            return piece
        case .code, .link:
            return AttributedString()
        }
    }
}
