import SwiftUI
import AtlasCore

// Inline spans + plain text — peel de AtlasMarkdownView+Rendering (régua ≤100).

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

    func plain(_ spans: [InlineSpan]) -> String {
        spans.map {
            switch $0 {
            case .text(let t), .bold(let t), .italic(let t), .code(let t): return t
            case .link(let t, _): return t
            }
        }.joined()
    }
}
