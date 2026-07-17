import Foundation

extension AtlasMarkdown {
    // MARK: - Block regex + helpers (peel de AtlasMarkdown+Blocks)

    static func re(_ p: String) -> NSRegularExpression { try! NSRegularExpression(pattern: p) }
    static let dividerRE = re("^\\s*([-*_])\\1{2,}\\s*$")
    static let fenceRE = re("^```(\\w*)\\s*$")
    static let fenceEndRE = re("^```\\s*$")
    static let headingRE = re("^(#{1,3})\\s+(.+?)\\s*#*\\s*$")
    static let ulistRE = re("^[-*+]\\s+")
    static let olistRE = re("^\\d+\\.\\s+")
    static let quoteRE = re("^>\\s?")
    static let tableSepRE = re("^\\s*\\|?\\s*:?-{2,}:?\\s*(\\|\\s*:?-{2,}:?\\s*)+\\|?\\s*$")

    static func range(_ ns: NSString) -> NSRange {
        NSRange(location: 0, length: ns.length)
    }
    static func firstMatch(_ r: NSRegularExpression, _ s: String, _ ns: NSString) -> NSTextCheckingResult? {
        r.firstMatch(in: s, range: range(ns))
    }
    static func test(_ r: NSRegularExpression, _ s: String) -> Bool {
        let ns = s as NSString
        return firstMatch(r, s, ns) != nil
    }
    static func strip(_ r: NSRegularExpression, _ s: String) -> String {
        let ns = s as NSString
        return r.stringByReplacingMatches(in: s, options: [], range: range(ns), withTemplate: "")
    }

    static func isBlockStart(_ line: String) -> Bool {
        test(headingRE, line) || test(ulistRE, line) || test(olistRE, line)
            || test(quoteRE, line) || line.hasPrefix("```") || test(dividerRE, line)
    }

    static func splitTableRow(_ line: String) -> [String] {
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
