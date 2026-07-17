import Foundation

/// Achatação de markdown — peel de AtlasMarkdown.

extension AtlasMarkdown {
    static func plain(_ block: MarkdownBlock) -> String {
        switch block {
        case .paragraph(let spans), .quote(let spans):
            return plain(spans)
        case .heading(_, let spans):
            return plain(spans)
        case .list(_, let items):
            return items.map { "• " + plain($0) }.joined(separator: "\n")
        case .code(let text, _):
            return text
        case .divider:
            return ""
        case .table(let headers, let rows):
            return ([headers] + rows).map { linha in
                linha.map(plain).joined(separator: " · ")
            }.joined(separator: "\n")
        }
    }

    static func plain(_ spans: [InlineSpan]) -> String {
        spans.map { span in
            switch span {
            case .text(let s), .bold(let s), .italic(let s), .code(let s): return s
            case .link(let text, _): return text
            }
        }.joined()
    }
}
