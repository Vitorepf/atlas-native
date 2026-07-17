import Foundation

extension AtlasRichInputPayload {
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
}
