import SwiftUI
import AtlasCore

// Bold emphasis — peel de AtlasMarkdownView+InlineMarkEmphasis.

extension AtlasMarkdownView {
    func inlineBoldMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = .system(size: base.size, weight: .semibold)
        piece.foregroundColor = AtlasTheme.textPrimary
        return piece
    }
}
