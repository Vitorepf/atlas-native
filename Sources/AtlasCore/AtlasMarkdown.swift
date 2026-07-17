import Foundation

// Parser de markdown do Atlas — porte verbatim de components/console/markdown/parse.ts.
// Escopo: o que os LLMs realmente emitem — **bold**, *italic*, ***bold-italic***,
// `code`, [text](url), headings (# ## ###), listas (- * + / 1.), quotes (> ),
// code fences (```), dividers (--- *** ___) e tabelas GFM. Dois passes: blocos,
// depois inline. Ênfase com underscore NÃO é suportada de propósito (falsos
// positivos de snake_case). Puro/Foundation → testável na CLI.
// Blocos → AtlasMarkdown+Blocks.swift · Plain → AtlasMarkdown+Plain.swift

public enum InlineSpan: Equatable, Sendable {
    case text(String)
    case bold(String)
    case italic(String)
    case code(String)
    case link(text: String, url: String)
}

public enum MarkdownBlock: Equatable, Sendable {
    case paragraph([InlineSpan])
    case heading(level: Int, spans: [InlineSpan])
    case list(ordered: Bool, items: [[InlineSpan]])
    case quote([InlineSpan])
    case code(text: String, lang: String?)
    case divider
    case table(headers: [[InlineSpan]], rows: [[[InlineSpan]]])
}

public enum AtlasMarkdown {
    public static func parse(_ text: String) -> [MarkdownBlock] { parseBlocks(text) }

    /// O texto sem a sintaxe — para onde não há como renderizar markdown.
    public static func plainText(_ text: String) -> String {
        parseBlocks(text).map(plain).joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Inline

    private static let inlineRE = try! NSRegularExpression(
        pattern: "(`+)([^`\\n]+?)\\1|\\[([^\\]\\n]+)\\]\\(([^)\\s]+)\\)|\\*\\*\\*([^*\\n]+?)\\*\\*\\*|\\*\\*([^*\\n]+?)\\*\\*|\\*([^*\\n]+?)\\*")
    private static let unescapeRE = try! NSRegularExpression(pattern: "\\\\([*_`\\[\\]()#>~\\\\-])")

    public static func parseInline(_ text: String) -> [InlineSpan] {
        var out: [InlineSpan] = []
        let ns = text as NSString
        var last = 0
        for m in inlineRE.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
            let idx = m.range.location
            if idx > last { out.append(.text(ns.substring(with: NSRange(location: last, length: idx - last)))) }
            if let g = group(m, 2, ns) { out.append(.code(g)) }
            else if let g = group(m, 3, ns) { out.append(.link(text: g, url: group(m, 4, ns) ?? "")) }
            else if let g = group(m, 5, ns) { out.append(.italic(g)) }
            else if let g = group(m, 6, ns) { out.append(.bold(g)) }
            else if let g = group(m, 7, ns) { out.append(.italic(g)) }
            last = m.range.location + m.range.length
        }
        if last < ns.length { out.append(.text(ns.substring(from: last))) }
        return out.map(unescape)
    }

    static func group(_ m: NSTextCheckingResult, _ i: Int, _ ns: NSString) -> String? {
        guard i < m.numberOfRanges else { return nil }
        let r = m.range(at: i)
        return r.location == NSNotFound ? nil : ns.substring(with: r)
    }

    private static func unescape(_ span: InlineSpan) -> InlineSpan {
        guard case .text(let t) = span else { return span }
        let ns = t as NSString
        let out = unescapeRE.stringByReplacingMatches(
            in: t, range: NSRange(location: 0, length: ns.length), withTemplate: "$1")
        return .text(out)
    }
}
