import SwiftUI
import AtlasCore

// Inline code/link marks — peel de AtlasMarkdownView+InlineMark.

extension AtlasMarkdownView {
    func inlineDecoratedMark(_ span: InlineSpan, base: InlineBase) -> AttributedString? {
        switch span {
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
        default:
            return nil
        }
    }
}
