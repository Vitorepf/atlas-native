import SwiftUI
import AtlasCore

// Inline emphasis marks — peel de AtlasMarkdownView+InlineMark.

extension AtlasMarkdownView {
    func inlineEmphasisMark(_ span: InlineSpan, base: InlineBase) -> AttributedString? {
        switch span {
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
        default:
            return nil
        }
    }
}
