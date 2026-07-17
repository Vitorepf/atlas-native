import SwiftUI
import AtlasCore

// Inline emphasis marks — peel de AtlasMarkdownView+InlineMark.
// Bold → AtlasMarkdownView+InlineMarkEmphasis+Bold.swift
// Italic → AtlasMarkdownView+InlineMarkEmphasis+Italic.swift

extension AtlasMarkdownView {
    func inlineEmphasisMark(_ span: InlineSpan, base: InlineBase) -> AttributedString? {
        switch span {
        case .bold(let t):
            return inlineBoldMark(t, base: base)
        case .italic(let t):
            return inlineItalicMark(t, base: base)
        default:
            return nil
        }
    }
}
