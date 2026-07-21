import SwiftUI
import AtlasCore

// Inline code/link marks — peel de AtlasMarkdownView+InlineMark.
// Code → AtlasMarkdownView+InlineMarkDecorated+Code.swift
// Link → AtlasMarkdownView+InlineMarkDecorated+Link.swift

extension AtlasMarkdownView {
    func inlineDecoratedMark(_ span: InlineSpan, base: InlineBase) -> AttributedString? {
        switch span {
        case .code(let t):
            return inlineCodeMark(t)
        case .link(let t, let url):
            return inlineLinkMark(t, url: url, base: base)
        default:
            return nil
        }
    }
}
