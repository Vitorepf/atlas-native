import Foundation

// Parser de markdown do Atlas — porte verbatim de components/console/markdown/parse.ts.
// Escopo: o que os LLMs realmente emitem — **bold**, *italic*, ***bold-italic***,
// `code`, [text](url), headings (# ## ###), listas (- * + / 1.), quotes (> ),
// code fences (```), dividers (--- *** ___) e tabelas GFM. Dois passes: blocos,
// depois inline. Ênfase com underscore NÃO é suportada de propósito (falsos
// positivos de snake_case). Puro/Foundation → testável na CLI.

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

    private static func group(_ m: NSTextCheckingResult, _ i: Int, _ ns: NSString) -> String? {
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

    // MARK: - Blocks

    private static func re(_ p: String) -> NSRegularExpression { try! NSRegularExpression(pattern: p) }
    private static let dividerRE = re("^\\s*([-*_])\\1{2,}\\s*$")
    private static let fenceRE = re("^```(\\w*)\\s*$")
    private static let fenceEndRE = re("^```\\s*$")
    private static let headingRE = re("^(#{1,3})\\s+(.+?)\\s*#*\\s*$")
    private static let ulistRE = re("^[-*+]\\s+")
    private static let olistRE = re("^\\d+\\.\\s+")
    private static let quoteRE = re("^>\\s?")
    private static let tableSepRE = re("^\\s*\\|?\\s*:?-{2,}:?\\s*(\\|\\s*:?-{2,}:?\\s*)+\\|?\\s*$")

    private static func test(_ r: NSRegularExpression, _ s: String) -> Bool {
        r.firstMatch(in: s, range: NSRange(location: 0, length: (s as NSString).length)) != nil
    }
    private static func strip(_ r: NSRegularExpression, _ s: String) -> String {
        let ns = s as NSString
        return r.stringByReplacingMatches(in: s, options: [], range: NSRange(location: 0, length: ns.length), withTemplate: "")
    }

    private static func parseBlocks(_ text: String) -> [MarkdownBlock] {
        let lines = text.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
        var blocks: [MarkdownBlock] = []
        var i = 0
        while i < lines.count {
            let line = lines[i]
            if line.trimmingCharacters(in: .whitespaces).isEmpty { i += 1; continue }

            if test(dividerRE, line) { blocks.append(.divider); i += 1; continue }

            if let f = fenceRE.firstMatch(in: line, range: NSRange(location: 0, length: (line as NSString).length)) {
                let lang = group(f, 1, line as NSString).flatMap { $0.isEmpty ? nil : $0 }
                var buf: [String] = []
                i += 1
                while i < lines.count && !test(fenceEndRE, lines[i]) { buf.append(lines[i]); i += 1 }
                if i < lines.count { i += 1 }
                blocks.append(.code(text: buf.joined(separator: "\n"), lang: lang))
                continue
            }

            if let h = headingRE.firstMatch(in: line, range: NSRange(location: 0, length: (line as NSString).length)) {
                let level = group(h, 1, line as NSString)?.count ?? 1
                blocks.append(.heading(level: level, spans: parseInline(group(h, 2, line as NSString) ?? "")))
                i += 1
                continue
            }

            if test(quoteRE, line) {
                var buf: [String] = []
                while i < lines.count && test(quoteRE, lines[i]) { buf.append(strip(quoteRE, lines[i])); i += 1 }
                blocks.append(.quote(parseInline(buf.joined(separator: " "))))
                continue
            }

            if test(ulistRE, line) {
                var items: [[InlineSpan]] = []
                while i < lines.count && test(ulistRE, lines[i]) { items.append(parseInline(strip(ulistRE, lines[i]))); i += 1 }
                blocks.append(.list(ordered: false, items: items))
                continue
            }

            if test(olistRE, line) {
                var items: [[InlineSpan]] = []
                while i < lines.count && test(olistRE, lines[i]) { items.append(parseInline(strip(olistRE, lines[i]))); i += 1 }
                blocks.append(.list(ordered: true, items: items))
                continue
            }

            if line.contains("|"), i + 1 < lines.count, test(tableSepRE, lines[i + 1]) {
                let headers = splitTableRow(line).map(parseInline)
                i += 2
                var rows: [[[InlineSpan]]] = []
                while i < lines.count, !lines[i].trimmingCharacters(in: .whitespaces).isEmpty,
                      lines[i].contains("|"), !isBlockStart(lines[i]) {
                    rows.append(splitTableRow(lines[i]).map(parseInline)); i += 1
                }
                blocks.append(.table(headers: headers, rows: rows))
                continue
            }

            var buf: [String] = []
            while i < lines.count, !lines[i].trimmingCharacters(in: .whitespaces).isEmpty, !isBlockStart(lines[i]) {
                buf.append(lines[i]); i += 1
            }
            blocks.append(.paragraph(parseInline(buf.joined(separator: " "))))
        }
        return blocks
    }

    private static func isBlockStart(_ line: String) -> Bool {
        test(re("^#{1,3}\\s"), line) || test(ulistRE, line) || test(olistRE, line)
            || test(quoteRE, line) || line.hasPrefix("```") || test(dividerRE, line)
    }

    private static func splitTableRow(_ line: String) -> [String] {
        var t = line.trimmingCharacters(in: .whitespaces)
        if t.hasPrefix("|") { t.removeFirst() }
        if t.hasSuffix("|") { t.removeLast() }
        var cells: [String] = []
        var current = ""
        let chars = Array(t)
        var i = 0
        while i < chars.count {
            if chars[i] == "\\", i + 1 < chars.count, chars[i + 1] == "|" { current += "|"; i += 2; continue }
            if chars[i] == "|" { cells.append(current.trimmingCharacters(in: .whitespaces)); current = ""; i += 1; continue }
            current.append(chars[i]); i += 1
        }
        cells.append(current.trimmingCharacters(in: .whitespaces))
        return cells
    }
}
