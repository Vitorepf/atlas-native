import SwiftUI
import AtlasCore

// Inline link mark — peel de AtlasMarkdownView+InlineMarkDecorated.

extension AtlasMarkdownView {
    func inlineLinkMark(_ text: String, url: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = .system(size: base.size, weight: .medium)
        piece.foregroundColor = AtlasTheme.prussian
        piece.underlineStyle = .single
        if let u = URL(string: url) { piece.link = u }
        return piece
    }
}
