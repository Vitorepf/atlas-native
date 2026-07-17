import SwiftUI
import AtlasCore

// Inline spans — peel de AtlasMarkdownView+Rendering (régua ≤100).
// Plain → AtlasMarkdownView+Plain.swift

extension AtlasMarkdownView {
    func inline(_ spans: [InlineSpan], base: InlineBase) -> AttributedString {
        var out = AttributedString()
        for span in spans {
            var piece: AttributedString
            switch span {
            case .text(let t):
                piece = AttributedString(t); piece.font = base.font; piece.foregroundColor = base.color
            case .bold(let t):
                piece = AttributedString(t)
                piece.font = .system(size: base.size, weight: .semibold)
                piece.foregroundColor = AtlasTheme.textPrimary
            case .italic(let t):
                piece = AttributedString(t)
                piece.font = AtlasFont.serifItalic(base.size)
                piece.foregroundColor = base.color
            case .code(let t):
                piece = AttributedString(" \(t) ")
                piece.font = AtlasFont.mono(13)
                piece.foregroundColor = AtlasTheme.textPrimary
                piece.backgroundColor = AtlasTheme.surface
            case .link(let t, let url):
                piece = AttributedString(t)
                piece.font = .system(size: base.size, weight: .medium)
                piece.foregroundColor = AtlasTheme.prussian
                piece.underlineStyle = .single
                if let u = URL(string: url) { piece.link = u }
            }
            out.append(piece)
        }
        return out
    }
}
