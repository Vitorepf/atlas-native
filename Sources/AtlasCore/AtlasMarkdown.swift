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

    /// O texto sem a sintaxe — para onde não há como renderizar markdown.
    ///
    /// A Lock Screen é o caso: a notificação recebia `bubble.text` cru e mostrava
    /// `**pronto**`, `## Resposta`, `[isto](http://…)` — a fonte, não a resposta.
    /// O mesmo campo que a tela entrega ao parser ia CRU para a notificação, e o
    /// operador longe do app lia sintaxe.
    ///
    /// Achata bloco e span: título vira frase, item de lista ganha "• ", código
    /// fica o código. Link vira o TEXTO dele — a URL não cabe numa linha de
    /// aviso e não é o que o operador quer ler ali.
    public static func plainText(_ text: String) -> String {
        parseBlocks(text).map(plain).joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func plain(_ block: MarkdownBlock) -> String {
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
            // Tabela não vira tabela numa linha de aviso: vira as células, na
            // ordem em que estão. Fingir grade em 140 caracteres seria pior.
            return ([headers] + rows).map { linha in
                linha.map(plain).joined(separator: " · ")
            }.joined(separator: "\n")
        }
    }

    private static func plain(_ spans: [InlineSpan]) -> String {
        spans.map { span in
            switch span {
            case .text(let s), .bold(let s), .italic(let s), .code(let s): return s
            case .link(let text, _): return text
            }
        }.joined()
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

    private static func range(_ ns: NSString) -> NSRange {
        NSRange(location: 0, length: ns.length)
    }
    private static func firstMatch(_ r: NSRegularExpression, _ s: String, _ ns: NSString) -> NSTextCheckingResult? {
        r.firstMatch(in: s, range: range(ns))
    }
    private static func test(_ r: NSRegularExpression, _ s: String) -> Bool {
        let ns = s as NSString
        return firstMatch(r, s, ns) != nil
    }
    private static func strip(_ r: NSRegularExpression, _ s: String) -> String {
        let ns = s as NSString
        return r.stringByReplacingMatches(in: s, options: [], range: range(ns), withTemplate: "")
    }

    private static func parseBlocks(_ text: String) -> [MarkdownBlock] {
        let lines = text.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
        var blocks: [MarkdownBlock] = []
        var i = 0
        while i < lines.count {
            let line = lines[i]
            let lineNS = line as NSString
            if line.trimmingCharacters(in: .whitespaces).isEmpty { i += 1; continue }

            if firstMatch(dividerRE, line, lineNS) != nil { blocks.append(.divider); i += 1; continue }

            if let f = firstMatch(fenceRE, line, lineNS) {
                let lang = group(f, 1, lineNS).flatMap { $0.isEmpty ? nil : $0 }
                var buf: [String] = []
                i += 1
                while i < lines.count && !test(fenceEndRE, lines[i]) { buf.append(lines[i]); i += 1 }
                if i < lines.count { i += 1 }
                blocks.append(.code(text: buf.joined(separator: "\n"), lang: lang))
                continue
            }

            if let h = firstMatch(headingRE, line, lineNS) {
                let level = group(h, 1, lineNS)?.count ?? 1
                blocks.append(.heading(level: level, spans: parseInline(group(h, 2, lineNS) ?? "")))
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
        test(headingRE, line) || test(ulistRE, line) || test(olistRE, line)
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
