import Foundation

enum HTTPDateParser {
    static func date(from value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss zzz"
        return formatter.date(from: value)
    }
}

// MARK: - queryString (verbatim de core.ts)

public enum QueryValue: Sendable {
    case string(String)
    case int(Int)
    case bool(Bool)
}

/// Porta de `queryString(params)` + `normalizeQueryValue` (lib/api/core.ts).
/// Gotchas fiéis: pula nil/""; `limit` numérico é clampado a [1,200]; boolean
/// vira "1"/"0" (Laravel `boolean` rejeita "true"/"false" → 422).
public func atlasQueryString(_ items: [(String, QueryValue?)]) -> String {
    var pairs: [(String, String)] = []
    for (key, value) in items {
        guard let normalized = normalizeQueryValue(key, value) else { continue }
        pairs.append((key, normalized))
    }
    if pairs.isEmpty { return "" }
    return "?" + pairs.map { "\(uriEncode($0.0))=\(uriEncode($0.1))" }.joined(separator: "&")
}

private func normalizeQueryValue(_ key: String, _ value: QueryValue?) -> String? {
    guard let value else { return nil }
    switch value {
    case .string(let s):
        return s.isEmpty ? nil : s
    case .int(let n):
        if key == "limit" { return String(min(200, max(1, n))) }
        return String(n)
    case .bool(let b):
        return b ? "1" : "0"
    }
}

/// Conjunto de `encodeURIComponent`: deixa `A-Za-z0-9-_.!~*'()`.
let encodeURIComponentAllowed: CharacterSet = {
    var s = CharacterSet.alphanumerics
    s.insert(charactersIn: "-_.!~*'()")
    return s
}()

private func uriEncode(_ s: String) -> String {
    s.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? s
}
