import SwiftUI
import AtlasCore

// Italic emphasis — peel de AtlasMarkdownView+InlineMarkEmphasis.

extension AtlasMarkdownView {
    func inlineItalicMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.serifItalic(base.size)
        piece.foregroundColor = base.color
        return piece
    }
}
