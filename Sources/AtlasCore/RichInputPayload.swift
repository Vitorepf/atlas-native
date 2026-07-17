import Foundation

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
}
