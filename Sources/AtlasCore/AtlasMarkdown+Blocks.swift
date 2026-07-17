import Foundation

extension AtlasMarkdown {
    // MARK: - Blocks

    static func parseBlocks(_ text: String) -> [MarkdownBlock] {
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
}
