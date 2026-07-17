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
