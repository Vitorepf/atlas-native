import Foundation

// Rich Input · L1 types — Codable wire shapes, limites pinados e helpers
// puros (FNV). Zero I/O, zero estado. O contrato (detectors/builders) vive
// em RichInputContract.swift; o engine consome estes tipos.
//
// Anti-drift: golden checks + fixtures do canon TS
// (packages/atlas-rich-input-canon/fixtures/rich-input.json).

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

// MARK: - Result shapes (detectors/builders em RichInputContract)

public struct AtlasDetectedUrl: Equatable, Sendable {
    public let url: String
    public let kind: String   // youtube | vimeo | github | generic
    public let refId: String?
}

public struct AtlasDetectedKind: Equatable, Sendable {
    public let kind: AtlasAttachmentKind   // nunca .url (URLs vêm do detector)
    public let language: String?
    public let reason: String
}

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
