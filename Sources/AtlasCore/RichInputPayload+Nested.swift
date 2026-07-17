import Foundation

extension AtlasRichInputPayload {
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

extension KeyedEncodingContainer {
    /// Encoda `null` EXPLÍCITO quando nil — o JSON do canon TS carrega os nulls.
    mutating func encodeNullable<T: Encodable>(_ value: T?, forKey key: Key) throws {
        if let value { try encode(value, forKey: key) } else { try encodeNil(forKey: key) }
    }
}
