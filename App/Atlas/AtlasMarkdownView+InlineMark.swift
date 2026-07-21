import SwiftUI
import AtlasCore

// Inline mark styles — peel de AtlasMarkdownView+Inline.
// Code/link → AtlasMarkdownView+InlineMarkDecorated.swift
// Emphasis → AtlasMarkdownView+InlineMarkEmphasis.swift
// Text → AtlasMarkdownView+InlineMark+Text.swift
// Fallback → AtlasMarkdownView+InlineMark+Fallback.swift

extension AtlasMarkdownView {
    func inlineMark(_ span: InlineSpan, base: InlineBase) -> AttributedString {
        if let decorated = inlineDecoratedMark(span, base: base) {
            return decorated
        }
        if let emphasis = inlineEmphasisMark(span, base: base) {
            return emphasis
        }
        return inlineMarkTextFallback(span, base: base)
    }
}
