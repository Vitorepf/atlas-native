import SwiftUI
import AtlasCore

// Inline mark styles — peel de AtlasMarkdownView+Inline.
// Code/link → AtlasMarkdownView+InlineMarkDecorated.swift
// Emphasis → AtlasMarkdownView+InlineMarkEmphasis.swift

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
            var piece = AttributedString(t)
            piece.font = base.font
            piece.foregroundColor = base.color
            return piece
        default:
            return AttributedString()
        }
    }
}
