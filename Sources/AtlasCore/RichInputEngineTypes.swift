import Foundation

// MARK: - Entrada/saída do engine

public struct AttachmentInput: Sendable {
    public var kind: AtlasAttachmentKind   // .image | .pdf | .text | .code (url nunca sobe bytes)
    public var fileName: String
    public var mimeType: String
    public var source: String              // camera|photos|files|clipboard|drop|picker|paste
    /// Chave estável para resume (path, itemIdentifier do Photos, …).
    public var identity: String
    public var bytes: any AttachmentByteSource
    public var width: Int?
    public var height: Int?

    public init(kind: AtlasAttachmentKind, fileName: String, mimeType: String, source: String,
                identity: String, bytes: any AttachmentByteSource,
                width: Int? = nil, height: Int? = nil) {
        self.kind = kind; self.fileName = fileName; self.mimeType = mimeType
        self.source = source; self.identity = identity; self.bytes = bytes
        self.width = width; self.height = height
    }
}

public struct UploadedAsset: Sendable {
    public let uploadedId: String
    /// SHA-256 hex local (streaming) — conferido contra o do servidor no complete.
    public let sha256: String
    public let input: AttachmentInput
}

/// Fases idênticas ao AiInteractionUploadProgress do RN; percent agregado
/// cross-arquivo, monotônico, 0...1.
public struct UploadProgress: Sendable, Equatable {
    public enum Phase: String, Sendable { case starting, uploading, finalizing, complete }
    public var phase: Phase
    public var fileName: String
    public var fileIndex: Int
    public var fileCount: Int
    public var sentBytes: Int
    public var totalBytes: Int
    public var percent: Double

    public init(phase: Phase, fileName: String, fileIndex: Int, fileCount: Int,
                sentBytes: Int, totalBytes: Int, percent: Double) {
        self.phase = phase; self.fileName = fileName; self.fileIndex = fileIndex
        self.fileCount = fileCount; self.sentBytes = sentBytes
        self.totalBytes = totalBytes; self.percent = percent
    }
}

/// O que entra no CREATE: uploaded_* no NÍVEL RAIZ (o que anexa de verdade) +
/// espelho no rich_input_payload (routing/audit) — nil sob a regra compact.
public struct RichInputInteractionFields: Sendable {
    public let uploadedImages: [String]
    public let uploadedDocuments: [String]
    public let richInputPayload: AtlasRichInputPayload?
}

public enum RichInputError: Error, CustomStringConvertible, Sendable {
    case unsupportedImageMime(String)
    case tooLarge(fileName: String, bytes: Int, max: Int)
    case sha256Mismatch(fileName: String, local: String, server: String)
    public var description: String {
        switch self {
        case .unsupportedImageMime(let m):
            return "imagem \(m) não suportada pelo servidor (png/jpeg/webp/gif) — converta antes de subir"
        case .tooLarge(let f, let b, let max):
            return "\(f): \(b) bytes excede o limite de \(max)"
        case .sha256Mismatch(let f, _, _):
            return "\(f): sha256 local ≠ servidor (upload corrompido)"
        }
    }
}
