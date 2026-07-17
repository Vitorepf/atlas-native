import Foundation

// Rich Input · L1 contract — detectors e builders do payload
// `atlas.rich_input.payload.v1`. Tipos/wire DTOs em RichInputTypes.swift.
//
// Anti-drift: golden checks comparam a saída destes builders byte-a-byte
// (estruturalmente, via JSONValue) com fixtures GERADAS PELO CANON TS
// (packages/atlas-rich-input-canon/fixtures/rich-input.json).
//
// Lição dura do servidor (AiInteractionController): uploaded_image_ids/
// uploaded_document_ids DENTRO deste payload NÃO anexam nada — são metadados
// de routing (detecção de visão no Atlas Decide). O que anexa de verdade são
// os campos uploaded_images/uploaded_documents no NÍVEL RAIZ do create.

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

// MARK: - Classificação de kind (porte de attachmentKind.ts + types.ts)

public enum AtlasAttachmentClassifier {
    public static let supportedImageMime: Set<String> =
        ["image/png", "image/jpeg", "image/jpg", "image/webp", "image/gif"]
    public static let supportedPdfMime: Set<String> = ["application/pdf"]
    public static let supportedTextMimePrefixes = ["text/", "application/json", "application/xml"]

    public static let codeLangByExt: [String: String] = [
        "ts": "typescript", "tsx": "tsx", "js": "javascript", "jsx": "jsx",
        "mjs": "javascript", "cjs": "javascript", "py": "python", "rb": "ruby",
        "rs": "rust", "go": "go", "java": "java", "c": "c", "cpp": "cpp",
        "cc": "cpp", "cxx": "cpp", "hpp": "cpp", "h": "c", "cs": "csharp",
        "php": "php", "swift": "swift", "kt": "kotlin", "scala": "scala",
        "sh": "bash", "bash": "bash", "zsh": "bash", "fish": "bash", "sql": "sql",
        "html": "html", "htm": "html", "xml": "xml", "css": "css", "scss": "css",
        "less": "css", "md": "markdown", "yml": "yaml", "yaml": "yaml",
        "toml": "toml", "json": "json", "jsonc": "json", "vue": "vue",
        "svelte": "svelte", "dart": "dart", "lua": "lua", "ex": "elixir",
        "exs": "elixir", "erl": "erlang", "elm": "elm", "hs": "haskell",
        "ml": "ocaml", "zig": "zig", "diff": "diff", "patch": "diff",
        "conf": "ini", "ini": "ini", "env": "bash", "dockerfile": "docker",
    ]

    public static func detectLanguage(fromFilename name: String) -> String? {
        let lower = name.lowercased()
        if lower == "dockerfile" || lower.hasSuffix("/dockerfile") { return "docker" }
        if lower == "makefile" { return "makefile" }
        let ext = lower.split(separator: ".").last.map(String.init) ?? ""
        return codeLangByExt[ext]
    }

    public static func detect(mimeType: String, fileName: String) -> AtlasDetectedKind {
        let mime = mimeType.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let name = fileName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if supportedImageMime.contains(mime) {
            return .init(kind: .image, language: nil, reason: "mime:\(mime)")
        }
        if supportedPdfMime.contains(mime) {
            return .init(kind: .pdf, language: nil, reason: "mime:\(mime)")
        }
        let language = detectLanguage(fromFilename: name)
        if let language, language != "markdown" {
            return .init(kind: .code, language: language, reason: "ext:\(language)")
        }
        let matchesTextPrefix = supportedTextMimePrefixes.contains { mime.hasPrefix($0) }
        if language == "markdown" {
            return .init(kind: .text, language: "markdown", reason: "ext:markdown")
        }
        if matchesTextPrefix {
            return .init(kind: .text, language: nil, reason: "mime:\(mime)")
        }
        return .init(kind: .text, language: nil, reason: "fallback:\(mime.isEmpty ? "unknown" : mime)")
    }
}

// MARK: - Builders do payload (porte de sourceManifest.ts)

public enum RichInputPayloadBuilder {
    /// `manifest-<fnv36>` quando não há id (TS: stableManifestId).
    static func stableManifestId(_ a: RichInputManifestSource) -> String {
        if let id = a.id, !id.isEmpty { return id }
        return "manifest-" + atlasFnv36("\(a.uri ?? "")|\(a.fileName)|\(a.size ?? 0)")
    }

    static func manifestEntry(_ a: RichInputManifestSource, uploadedId: String?,
                              forcedKind: String?) -> AtlasRichInputPayload.ManifestEntry {
        let kind: AtlasAttachmentKind = forcedKind == "image"
            ? .image
            : AtlasAttachmentClassifier.detect(mimeType: a.mimeType, fileName: a.fileName).kind
        return .init(id: stableManifestId(a), kind: kind, fileName: a.fileName,
                     mimeType: a.mimeType, size: (a.size ?? 0) > 0 ? a.size! : 0,
                     uploadedId: uploadedId, sourceHash: nil, source: a.source ?? "app")
    }

    public static func urlAttachment(from detected: AtlasDetectedUrl) -> AtlasRichInputPayload.UrlAttachment {
        let canonicalUrl = detected.kind == "youtube"
            ? (AtlasURLDetector.normalizeYouTubeUrl(detected.url) ?? detected.url)
            : detected.url
        return .init(
            url: canonicalUrl, kind: detected.kind, title: nil, author: nil, durationSec: nil,
            thumbnailUrl: detected.kind == "youtube" && detected.refId != nil
                ? "https://img.youtube.com/vi/\(detected.refId!)/hqdefault.jpg" : nil,
            refId: detected.refId)
    }

    public static func urlAttachments(fromText text: String,
                                      limits: AtlasAttachmentLimits = .canonical) -> [AtlasRichInputPayload.UrlAttachment] {
        AtlasURLDetector.extractUrls(text)
            .prefix(limits.maxUrls)
            .map { urlAttachment(from: AtlasURLDetector.classify($0)) }
    }

    static func urlManifestEntry(_ u: AtlasRichInputPayload.UrlAttachment) -> AtlasRichInputPayload.ManifestEntry {
        .init(id: "url-" + atlasFnv36(u.url), kind: .url, fileName: u.url,
              mimeType: "text/uri-list", size: 0, uploadedId: nil, sourceHash: nil, source: "paste")
    }

    /// Ordem: imagens (na ordem dos ids), depois arquivos, depois URLs —
    /// mesma dos arrays paralelos do envio (buildSourceManifest do TS).
    public static func sourceManifest(
        imageAttachments: [RichInputManifestSource], uploadedImageIds: [String],
        fileAttachments: [RichInputManifestSource], uploadedDocumentIds: [String],
        urlAttachments: [AtlasRichInputPayload.UrlAttachment]
    ) -> [AtlasRichInputPayload.ManifestEntry] {
        var manifest: [AtlasRichInputPayload.ManifestEntry] = []
        for (idx, a) in imageAttachments.enumerated() {
            manifest.append(manifestEntry(a, uploadedId: idx < uploadedImageIds.count ? uploadedImageIds[idx] : nil,
                                          forcedKind: "image"))
        }
        for (idx, a) in fileAttachments.enumerated() {
            manifest.append(manifestEntry(a, uploadedId: idx < uploadedDocumentIds.count ? uploadedDocumentIds[idx] : nil,
                                          forcedKind: "file"))
        }
        for u in urlAttachments { manifest.append(urlManifestEntry(u)) }
        return manifest
    }

    /// buildRichInputPayload do TS: urls derivadas do inputText quando não dadas;
    /// text_blocks vazio por default (server só consome no Forge).
    public static func build(
        imageAttachments: [RichInputManifestSource] = [], uploadedImageIds: [String] = [],
        fileAttachments: [RichInputManifestSource] = [], uploadedDocumentIds: [String] = [],
        inputText: String = "",
        urlAttachments: [AtlasRichInputPayload.UrlAttachment]? = nil,
        textBlocks: [AtlasRichInputPayload.TextBlock] = []
    ) -> AtlasRichInputPayload {
        let urls = urlAttachments ?? Self.urlAttachments(fromText: inputText)
        return AtlasRichInputPayload(
            uploadedImageIds: uploadedImageIds,
            uploadedDocumentIds: uploadedDocumentIds,
            textBlocks: textBlocks,
            urlAttachments: urls,
            sourceManifest: sourceManifest(
                imageAttachments: imageAttachments, uploadedImageIds: uploadedImageIds,
                fileAttachments: fileAttachments, uploadedDocumentIds: uploadedDocumentIds,
                urlAttachments: urls))
    }

    /// Regra compact ÚNICA (resolve compactRichInput desktop vs hasRichInputPayload
    /// mobile): o payload só existe se uma das 4 listas REAIS tem item —
    /// source_manifest sozinho NÃO conta.
    public static func compact(_ p: AtlasRichInputPayload) -> AtlasRichInputPayload? {
        let empty = p.uploadedImageIds.isEmpty && p.uploadedDocumentIds.isEmpty
            && p.textBlocks.isEmpty && p.urlAttachments.isEmpty
        return empty ? nil : p
    }
}
