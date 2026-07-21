import SwiftUI
import AtlasCore

// Plain text mark — peel de AtlasMarkdownView+InlineMark.

extension AtlasMarkdownView {
    func inlineTextMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = base.font
        piece.foregroundColor = base.color
        return piece
    }
}
