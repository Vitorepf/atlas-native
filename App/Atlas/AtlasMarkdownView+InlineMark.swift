import SwiftUI
import AtlasCore

// Inline mark styles — peel de AtlasMarkdownView+Inline.

extension AtlasMarkdownView {
    func inlineMark(_ span: InlineSpan, base: InlineBase) -> AttributedString {
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
        case .code(let t):
            var piece = AttributedString(" \(t) ")
            piece.font = AtlasFont.mono(13)
            piece.foregroundColor = AtlasTheme.textPrimary
            piece.backgroundColor = AtlasTheme.surface
            return piece
        case .link(let t, let url):
            var piece = AttributedString(t)
            piece.font = .system(size: base.size, weight: .medium)
            piece.foregroundColor = AtlasTheme.prussian
            piece.underlineStyle = .single
            if let u = URL(string: url) { piece.link = u }
            return piece
        }
    }
}
