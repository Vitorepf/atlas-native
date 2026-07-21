import SwiftUI
import AtlasCore

// Cycle 022 fuse → AtlasMarkdownView+Inline.swift

extension AtlasMarkdownView {
    func inline(_ spans: [InlineSpan], base: InlineBase) -> AttributedString {
        var out = AttributedString()
        for span in spans {
            out.append(inlineMark(span, base: base))
        }
        return out
    }
}

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

extension AtlasMarkdownView {
    func inlineTextMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = base.font
        piece.foregroundColor = base.color
        return piece
    }
}

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

extension AtlasMarkdownView {
    func inlineCodeMark(_ text: String) -> AttributedString {
        var piece = AttributedString(" \(text) ")
        piece.font = AtlasFont.mono(13)
        piece.foregroundColor = AtlasTheme.textPrimary
        piece.backgroundColor = AtlasTheme.surface
        return piece
    }
}

extension AtlasMarkdownView {
    func inlineLinkMark(_ text: String, url: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.sans(base.size, weight: .medium, at: base.typeSize)
        piece.foregroundColor = AtlasTheme.prussian
        piece.underlineStyle = .single
        if let u = URL(string: url) { piece.link = u }
        return piece
    }
}

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

extension AtlasMarkdownView {
    func inlineBoldMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.sans(base.size, weight: .semibold, at: base.typeSize)
        piece.foregroundColor = AtlasTheme.textPrimary
        return piece
    }
}

extension AtlasMarkdownView {
    func inlineItalicMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.serifItalic(base.size)
        piece.foregroundColor = base.color
        return piece
    }
}

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
