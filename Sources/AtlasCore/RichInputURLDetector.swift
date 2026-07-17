import Foundation

// MARK: - Detector de URL (porte de urlDetector.ts + normalizeYouTubeUrl)

public enum AtlasURLDetector {
    // /\bhttps?:\/\/[^\s<>"')]+/gi
    private static let urlRegex = try! NSRegularExpression(
        pattern: #"\bhttps?://[^\s<>"')]+"#, options: [.caseInsensitive])

    // classifyUrl (urlDetector.ts) — padrões EXATOS
    private static let youtubePatterns = [
        try! NSRegularExpression(pattern: #"(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/|youtube\.com/shorts/)([A-Za-z0-9_-]{11})"#),
        try! NSRegularExpression(pattern: #"youtube\.com/live/([A-Za-z0-9_-]{11})"#),
    ]
    private static let vimeoPattern = try! NSRegularExpression(
        pattern: #"vimeo\.com/(?:video/|channels/[^/]+/|groups/[^/]+/videos/)?(\d+)"#)
    private static let githubPattern = try! NSRegularExpression(
        pattern: #"github\.com/([^/]+)/([^/?#]+)"#)

    // extractYouTubeVideoId (youtube.ts) — conjunto MAIOR que o do classify
    // (aceita params antes do v= e m.youtube) — usado pelo normalize.
    private static let youtubeIdPatterns = [
        try! NSRegularExpression(pattern: #"(?:youtube\.com/watch\?(?:[^#\s]*&)?v=)([A-Za-z0-9_-]{11})"#),
        try! NSRegularExpression(pattern: #"(?:youtu\.be/)([A-Za-z0-9_-]{11})"#),
        try! NSRegularExpression(pattern: #"(?:youtube\.com/embed/)([A-Za-z0-9_-]{11})"#),
        try! NSRegularExpression(pattern: #"(?:youtube\.com/shorts/)([A-Za-z0-9_-]{11})"#),
        try! NSRegularExpression(pattern: #"(?:youtube\.com/live/)([A-Za-z0-9_-]{11})"#),
        try! NSRegularExpression(pattern: #"(?:m\.youtube\.com/watch\?(?:[^#\s]*&)?v=)([A-Za-z0-9_-]{11})"#),
    ]
    private static let timestampRegex = try! NSRegularExpression(pattern: #"[?&#]t=(\d+)(?:s)?\b"#)

    /// Dedup preservando ordem (1ª ocorrência vence) — igual ao TS.
    public static func extractUrls(_ text: String) -> [String] {
        let ns = text as NSString
        var seen = Set<String>(), out: [String] = []
        for m in urlRegex.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
            let u = ns.substring(with: m.range)
            if seen.insert(u).inserted { out.append(u) }
        }
        return out
    }

    public static func classify(_ raw: String) -> AtlasDetectedUrl {
        let url = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        for re in youtubePatterns {
            if let id = firstGroup(re, url) { return .init(url: url, kind: "youtube", refId: id) }
        }
        if let id = firstGroup(vimeoPattern, url) { return .init(url: url, kind: "vimeo", refId: id) }
        if let m = firstMatch(githubPattern, url) {
            let owner = m[0]
            var repo = m[1]
            if repo.hasSuffix(".git") { repo = String(repo.dropLast(4)) }
            return .init(url: url, kind: "github", refId: "\(owner)/\(repo)")
        }
        return .init(url: url, kind: "generic", refId: nil)
    }

    public static func extractYouTubeVideoId(_ url: String?) -> String? {
        guard let url else { return nil }
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        for re in youtubeIdPatterns {
            if let id = firstGroup(re, trimmed) { return id }
        }
        return nil
    }

    /// Canonicaliza para `https://www.youtube.com/watch?v=ID`, preservando `t=N`
    /// (derruba o `s` final). `nil` se não for YouTube reconhecível.
    public static func normalizeYouTubeUrl(_ url: String?) -> String? {
        guard let videoId = extractYouTubeVideoId(url), let url else { return nil }
        let raw = url.trimmingCharacters(in: .whitespacesAndNewlines)
        var timestamp: Int? = nil
        if let t = firstGroup(timestampRegex, raw), let parsed = Int(t), parsed > 0 {
            timestamp = parsed
        }
        let base = "https://www.youtube.com/watch?v=\(videoId)"
        return timestamp.map { "\(base)&t=\($0)" } ?? base
    }

    private static func firstGroup(_ re: NSRegularExpression, _ s: String) -> String? {
        firstMatch(re, s)?.first
    }
    private static func firstMatch(_ re: NSRegularExpression, _ s: String) -> [String]? {
        let ns = s as NSString
        guard let m = re.firstMatch(in: s, range: NSRange(location: 0, length: ns.length)) else { return nil }
        return (1..<m.numberOfRanges).map { i in
            m.range(at: i).location == NSNotFound ? "" : ns.substring(with: m.range(at: i))
        }
    }
}
