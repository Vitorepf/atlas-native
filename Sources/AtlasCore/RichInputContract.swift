import Foundation

// Rich Input · L1 — o CONTRATO, espelho 1:1 do servidor e do canon TS
// (@atlas/rich-input-canon). Zero I/O, zero estado: tipos Codable, limites
// pinados, detector de URL e os builders do payload `atlas.rich_input.payload.v1`.
//
// Anti-drift: os golden checks comparam a saída destes builders byte-a-byte
// (estruturalmente, via JSONValue) com fixtures GERADAS PELO CANON TS
// (packages/atlas-rich-input-canon/fixtures/rich-input.json). Mudar um lado
// sem o outro quebra o check — pino bidirecional.
//
// Lição dura do servidor (AiInteractionController): uploaded_image_ids/
// uploaded_document_ids DENTRO deste payload NÃO anexam nada — são metadados
// de routing (detecção de visão no Atlas Decide). O que anexa de verdade são
// os campos uploaded_images/uploaded_documents no NÍVEL RAIZ do create.

// MARK: - Limites (pinados 1:1 com StoreAiInteractionRequest + canon TS)

public struct AtlasAttachmentLimits: Sendable {
    public static let canonical = AtlasAttachmentLimits()
    public let maxImages = 8
    public let maxPdfs = 4
    public let maxTextFiles = 8
    public let maxUrls = 16
    public let maxImageBytes = 20_971_520
    public let maxPdfBytes = 20_971_520
    public let maxTextBytes = 4_194_304
    public let maxTextPreviewChars = 200_000
    public let maxImageDimension = 2048
    public let imageJpegQuality = 0.86
    public let imageWebpQuality = 0.86
    /// == atlas.attachments.chunked_upload.chunk_max_bytes do servidor (tamanho
    /// DECODIFICADO). Decisão única: mata o drift 768KB (RN) vs 1.5MB (desktop).
    public let chunkBytes = 1_572_864
    public init() {}
}

public enum AtlasAttachmentKind: String, Codable, Sendable {
    case image, pdf, text, code, url
}

// MARK: - Payload `atlas.rich_input.payload.v1`

/// Chaves snake_case EXPLÍCITAS + nulls EXPLÍCITOS (o TS emite `title: null`,
/// não omite) — para a fixture bater estruturalmente. O struct pode ser
/// embutido tanto no encoder .convertToSnakeCase do AtlasClient (chaves snake
/// são idempotentes sob a conversão) quanto dentro de JSONObject.
public struct AtlasRichInputPayload: Codable, Equatable, Sendable {
    public static let schemaVersion = "atlas.rich_input.payload.v1"

    public var uploadedImageIds: [String]
    public var uploadedDocumentIds: [String]
    public var textBlocks: [TextBlock]
    public var urlAttachments: [UrlAttachment]
    public var sourceManifest: [ManifestEntry]
    /// hex sha256 da serialização canônica do manifest — opcional, omitido se nil.
    public var manifestSha256: String?

    public init(uploadedImageIds: [String] = [], uploadedDocumentIds: [String] = [],
                textBlocks: [TextBlock] = [], urlAttachments: [UrlAttachment] = [],
                sourceManifest: [ManifestEntry] = [], manifestSha256: String? = nil) {
        self.uploadedImageIds = uploadedImageIds
        self.uploadedDocumentIds = uploadedDocumentIds
        self.textBlocks = textBlocks
        self.urlAttachments = urlAttachments
        self.sourceManifest = sourceManifest
        self.manifestSha256 = manifestSha256
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case uploadedImageIds = "uploaded_image_ids"
        case uploadedDocumentIds = "uploaded_document_ids"
        case textBlocks = "text_blocks"
        case urlAttachments = "url_attachments"
        case sourceManifest = "source_manifest"
        case hashes
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(Self.schemaVersion, forKey: .schemaVersion)
        try c.encode(uploadedImageIds, forKey: .uploadedImageIds)
        try c.encode(uploadedDocumentIds, forKey: .uploadedDocumentIds)
        try c.encode(textBlocks, forKey: .textBlocks)
        try c.encode(urlAttachments, forKey: .urlAttachments)
        try c.encode(sourceManifest, forKey: .sourceManifest)
        if let manifestSha256 {
            try c.encode(["manifest_sha256": manifestSha256], forKey: .hashes)
        }
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        uploadedImageIds = try c.decodeIfPresent([String].self, forKey: .uploadedImageIds) ?? []
        uploadedDocumentIds = try c.decodeIfPresent([String].self, forKey: .uploadedDocumentIds) ?? []
        textBlocks = try c.decodeIfPresent([TextBlock].self, forKey: .textBlocks) ?? []
        urlAttachments = try c.decodeIfPresent([UrlAttachment].self, forKey: .urlAttachments) ?? []
        sourceManifest = try c.decodeIfPresent([ManifestEntry].self, forKey: .sourceManifest) ?? []
        let hashes = try c.decodeIfPresent([String: String].self, forKey: .hashes)
        manifestSha256 = hashes?["manifest_sha256"]
    }

    public struct TextBlock: Codable, Equatable, Sendable {
        public var fileName: String
        public var mimeType: String
        public var language: String?
        public var content: String
        /// Presente só quando a fonte é PDF (TS: `page_count?` — omitido se nil).
        public var pageCount: Int?

        public init(fileName: String, mimeType: String, language: String?,
                    content: String, pageCount: Int? = nil) {
            self.fileName = fileName; self.mimeType = mimeType
            self.language = language; self.content = content; self.pageCount = pageCount
        }

        enum CodingKeys: String, CodingKey {
            case fileName = "file_name", mimeType = "mime_type", language, content
            case pageCount = "page_count"
        }
        public func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(fileName, forKey: .fileName)
            try c.encode(mimeType, forKey: .mimeType)
            try c.encodeNullable(language, forKey: .language)
            try c.encode(content, forKey: .content)
            try c.encodeIfPresent(pageCount, forKey: .pageCount)
        }
    }

    public struct UrlAttachment: Codable, Equatable, Sendable {
        public var url: String
        /// 'youtube' | 'vimeo' | 'github' | 'generic' — youtube exige refId de
        /// 11 chars no servidor (422 sem ele).
        public var kind: String
        public var title: String?
        public var author: String?
        public var durationSec: Int?
        public var thumbnailUrl: String?
        public var refId: String?

        public init(url: String, kind: String, title: String? = nil, author: String? = nil,
                    durationSec: Int? = nil, thumbnailUrl: String? = nil, refId: String? = nil) {
            self.url = url; self.kind = kind; self.title = title; self.author = author
            self.durationSec = durationSec; self.thumbnailUrl = thumbnailUrl; self.refId = refId
        }

        enum CodingKeys: String, CodingKey {
            case url, kind, title, author
            case durationSec = "duration_sec", thumbnailUrl = "thumbnail_url", refId = "ref_id"
        }
        public func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(url, forKey: .url)
            try c.encode(kind, forKey: .kind)
            try c.encodeNullable(title, forKey: .title)
            try c.encodeNullable(author, forKey: .author)
            try c.encodeNullable(durationSec, forKey: .durationSec)
            try c.encodeNullable(thumbnailUrl, forKey: .thumbnailUrl)
            try c.encodeNullable(refId, forKey: .refId)
        }
    }

    public struct ManifestEntry: Codable, Equatable, Sendable {
        public var id: String
        public var kind: AtlasAttachmentKind
        public var fileName: String
        public var mimeType: String
        public var size: Int
        public var uploadedId: String?
        public var sourceHash: String?
        public var source: String

        public init(id: String, kind: AtlasAttachmentKind, fileName: String, mimeType: String,
                    size: Int, uploadedId: String?, sourceHash: String?, source: String) {
            self.id = id; self.kind = kind; self.fileName = fileName; self.mimeType = mimeType
            self.size = size; self.uploadedId = uploadedId; self.sourceHash = sourceHash
            self.source = source
        }

        enum CodingKeys: String, CodingKey {
            case id, kind, size, source
            case fileName = "file_name", mimeType = "mime_type"
            case uploadedId = "uploaded_id", sourceHash = "source_hash"
        }
        public func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(id, forKey: .id)
            try c.encode(kind, forKey: .kind)
            try c.encode(fileName, forKey: .fileName)
            try c.encode(mimeType, forKey: .mimeType)
            try c.encode(size, forKey: .size)
            try c.encodeNullable(uploadedId, forKey: .uploadedId)
            try c.encodeNullable(sourceHash, forKey: .sourceHash)
            try c.encode(source, forKey: .source)
        }
    }
}

private extension KeyedEncodingContainer {
    /// Encoda `null` EXPLÍCITO quando nil — o JSON do canon TS carrega os nulls.
    mutating func encodeNullable<T: Encodable>(_ value: T?, forKey key: Key) throws {
        if let value { try encode(value, forKey: key) } else { try encodeNil(forKey: key) }
    }
}

// MARK: - Wire DTOs do upload chunked (AiChunkedUploadController, campo a campo)

public struct ChunkStartRequest: Encodable, Sendable {
    /// Sanitizado server-side p/ [A-Za-z0-9._-], vira "up_"+valor. SEM escopo por
    /// device no servidor — inclua salt de instalação na derivação.
    public var clientUploadId: String
    /// "image" | "file" — meta informacional; o pipeline real é decidido por QUAL
    /// array do create recebe o id (uploaded_images vs uploaded_documents).
    public var kind: String
    public var fileName: String
    public var mimeType: String
    /// 1..20_971_520
    public var totalBytes: Int
    public var source: String

    public init(clientUploadId: String, kind: String, fileName: String,
                mimeType: String, totalBytes: Int, source: String) {
        self.clientUploadId = clientUploadId; self.kind = kind; self.fileName = fileName
        self.mimeType = mimeType; self.totalBytes = totalBytes; self.source = source
    }
}

public struct ChunkStartResponse: Decodable, Sendable {
    public struct Upload: Decodable, Sendable {
        public let id: String
        /// Índices já em disco — protocolo de resume: reenviar só os ausentes.
        public let receivedChunks: [Int]?
    }
    public let upload: Upload
}

public struct ChunkPartRequest: Encodable, Sendable {
    public var index: Int          // 0..10000
    public var totalChunks: Int    // reenviado em todo chunk; último valor vence
    public var offset: Int         // aceito e IGNORADO pelo servidor (paridade de wire)
    /// Tamanho DECODIFICADO — servidor valida strlen(base64_decode)==bytes.
    public var bytes: Int
    public var chunkBase64: String

    public init(index: Int, totalChunks: Int, offset: Int, bytes: Int, chunkBase64: String) {
        self.index = index; self.totalChunks = totalChunks; self.offset = offset
        self.bytes = bytes; self.chunkBase64 = chunkBase64
    }
}

public struct ChunkPartResponse: Decodable, Sendable {
    public struct Upload: Decodable, Sendable {
        public let id: String
        public let index: Int?
        public let receivedChunks: [Int]?
    }
    public let upload: Upload
}

public struct ChunkCompleteResponse: Decodable, Sendable {
    public struct Upload: Decodable, Sendable {
        public let id: String
        public let bytes: Int?
        /// Computado pelo servidor — a ÚNICA verificação de integridade fim-a-fim.
        public let sha256: String?
    }
    public let upload: Upload
}

// MARK: - FNV-1a 32-bit (bit-igual ao canon TS: Math.imul + charCodeAt UTF-16)

/// `Math.abs(hash >>> 0).toString(36)` do JS. Opera sobre code units UTF-16
/// (charCodeAt) com aritmética wrapping de 32 bits — mesmos bits do Math.imul.
public func atlasFnv36(_ input: String) -> String {
    var hash: UInt32 = 2_166_136_261
    for unit in input.utf16 {
        hash ^= UInt32(unit)
        hash = hash &* 16_777_619
    }
    return String(hash, radix: 36)
}

// MARK: - Detector de URL (porte de urlDetector.ts + normalizeYouTubeUrl)

public struct AtlasDetectedUrl: Equatable, Sendable {
    public let url: String
    public let kind: String   // youtube | vimeo | github | generic
    public let refId: String?
}

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

public struct AtlasDetectedKind: Equatable, Sendable {
    public let kind: AtlasAttachmentKind   // nunca .url (URLs vêm do detector)
    public let language: String?
    public let reason: String
}

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

/// Shape mínimo que o builder consome (ManifestAttachmentLike do TS).
public struct RichInputManifestSource: Sendable {
    public var id: String?
    public var uri: String?
    public var fileName: String
    public var mimeType: String
    public var size: Int?
    public var source: String?

    public init(id: String? = nil, uri: String? = nil, fileName: String,
                mimeType: String, size: Int? = nil, source: String? = nil) {
        self.id = id; self.uri = uri; self.fileName = fileName
        self.mimeType = mimeType; self.size = size; self.source = source
    }
}

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
