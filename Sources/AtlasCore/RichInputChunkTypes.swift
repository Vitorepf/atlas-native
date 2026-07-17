import Foundation

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
