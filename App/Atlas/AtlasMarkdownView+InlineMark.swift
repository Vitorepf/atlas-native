import SwiftUI
import AtlasCore

// Inline mark styles — peel de AtlasMarkdownView+Inline.
// Code/link → AtlasMarkdownView+InlineMarkDecorated.swift
// Emphasis → AtlasMarkdownView+InlineMarkEmphasis.swift
// Text → AtlasMarkdownView+InlineMark+Text.swift

extension AtlasMarkdownView {
    func inlineMark(_ span: InlineSpan, base: InlineBase) -> AttributedString {
        if let decorated = inlineDecoratedMark(span, base: base) {
            return decorated
        }
        if let emphasis = inlineEmphasisMark(span, base: base) {
            return emphasis
        }
        switch span {
        case .text(let t):
            return inlineTextMark(t, base: base)
        default:
            return AttributedString()
        }
    }
}
