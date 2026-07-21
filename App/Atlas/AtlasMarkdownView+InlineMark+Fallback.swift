import SwiftUI
import AtlasCore

// Inline mark text fallback — peel de AtlasMarkdownView+InlineMark.

extension AtlasMarkdownView {
    func inlineMarkTextFallback(_ span: InlineSpan, base: InlineBase) -> AttributedString {
        switch span {
        case .text(let t):
            return inlineTextMark(t, base: base)
        default:
            return AttributedString()
        }
    }
}
