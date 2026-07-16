import Foundation
import CryptoKit

// Rich Input · L2 — o ENGINE: a pipeline única de upload que iOS hoje e o
// macOS futuro consomem. Melhorar resume/retry/hash/progresso aqui melhora os
// dois apps por construção — não existe "outro lado".
//
// Dois seams com o mundo (e só esses):
//   1. AttachmentByteSource — a plataforma entrega bytes por offset; o engine
//      nunca vê PhotosPickerItem/NSOpenPanel/URI.
//   2. UploadTransport — 3 métodos espelhando os 3 endpoints chunked; o
//      AtlasClient conforma (rede real) e o InMemoryUploadTransport (checks)
//      prova o loop inteiro offline.
//
// Decisões gravadas (cada uma resolve um drift RN↔desktop catalogado):
//   chunk 1.5MB (limite do server; mata 768KB vs 1.5MB) · resume por chave
//   estável + installSalt (staging do server NÃO escopa por device) · SEM
//   réplica bit-igual do Math.imul pra chave (resume cross-runtime não existe)
//   · source_hash preenchido via SHA-256 streaming (RN/desktop mandam null) ·
//   SEM fallback multipart (FileHandle não falha em leitura por offset; o
//   fallback silencioso do RN mascarava erros e re-subia 20MB).

// MARK: - Seam 1 · bytes por offset

public protocol AttachmentByteSource: Sendable {
    var totalBytes: Int { get }
    func read(offset: Int, length: Int) throws -> Data
}

public struct DataByteSource: AttachmentByteSource {
    private let data: Data
    public var totalBytes: Int { data.count }
    public init(_ data: Data) { self.data = data }
    public func read(offset: Int, length: Int) throws -> Data {
        let end = min(offset + length, data.count)
        guard offset >= 0, offset < end else { return Data() }
        return data.subdata(in: offset..<end)
    }
}

/// FileHandle com seek+read — Files/fileImporter/NSOpenPanel. Diferente do
/// expo-file-system, leitura por offset NUNCA é indisponível → sem fallback.
public struct FileByteSource: AttachmentByteSource {
    private let handle: FileByteSourceHandle
    public let totalBytes: Int
    public init(url: URL) throws {
        let scoped = url.startAccessingSecurityScopedResource()
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
            let openHandle = try FileHandle(forReadingFrom: url)
            self.totalBytes = (attrs[.size] as? Int) ?? (attrs[.size] as? NSNumber)?.intValue ?? 0
            self.handle = FileByteSourceHandle(handle: openHandle, scopedURL: scoped ? url : nil)
        } catch {
            if scoped { url.stopAccessingSecurityScopedResource() }
            throw error
        }
    }
    public func read(offset: Int, length: Int) throws -> Data {
        try handle.read(offset: offset, length: length)
    }
}

private final class FileByteSourceHandle: @unchecked Sendable {
    private let handle: FileHandle
    private let scopedURL: URL?
    private let lock = NSLock()

    init(handle: FileHandle, scopedURL: URL?) {
        self.handle = handle
        self.scopedURL = scopedURL
    }

    deinit {
        try? handle.close()
        scopedURL?.stopAccessingSecurityScopedResource()
    }

    func read(offset: Int, length: Int) throws -> Data {
        lock.lock()
        defer { lock.unlock() }
        try handle.seek(toOffset: UInt64(offset))
        return try handle.read(upToCount: length) ?? Data()
    }
}

// MARK: - Seam 2 · transporte (3 endpoints, nada mais)

public protocol UploadTransport: Sendable {
    func start(_ request: ChunkStartRequest) async throws -> ChunkStartResponse
    func sendChunk(uploadId: String, _ body: ChunkPartRequest) async throws -> ChunkPartResponse
    func complete(uploadId: String) async throws -> ChunkCompleteResponse
}

// MARK: - Retry (porte de uploadRetry.ts: 3× · 280ms × 2^(n-1))

public struct RetryPolicy: Sendable {
    public static let canonical = RetryPolicy(attempts: 3, baseDelayMs: 280)
    public let attempts: Int
    public let baseDelayMs: Int
    public init(attempts: Int, baseDelayMs: Int) {
        self.attempts = max(1, attempts); self.baseDelayMs = max(0, baseDelayMs)
    }
}

public func atlasWithRetry<T: Sendable>(
    _ policy: RetryPolicy = .canonical,
    _ body: @Sendable () async throws -> T
) async throws -> T {
    var lastError: Error?
    for attempt in 1...policy.attempts {
        do { return try await body() } catch {
            lastError = error
            if error is CancellationError { throw error }
            if attempt >= policy.attempts { throw error }
            let delayMs = policy.baseDelayMs * (1 << (attempt - 1))   // 280/560/1120
            try await Task.sleep(nanoseconds: UInt64(delayMs) * 1_000_000)
        }
    }
    throw lastError ?? CancellationError()
}

// MARK: - Chunk math (função pura, golden-checkável)

public struct AtlasChunkPlan: Equatable, Sendable {
    public let index: Int
    public let offset: Int
    public let length: Int
}

public func atlasChunkPlans(totalBytes: Int, chunkBytes: Int) -> [AtlasChunkPlan] {
    guard totalBytes > 0, chunkBytes > 0 else { return [] }
    let count = (totalBytes + chunkBytes - 1) / chunkBytes
    return (0..<count).map { i in
        AtlasChunkPlan(index: i, offset: i * chunkBytes,
                       length: min(chunkBytes, totalBytes - i * chunkBytes))
    }
}

/// Chave de resume estável por (identidade, arquivo, bytes) + salt de
/// instalação — o staging do servidor NÃO escopa client_upload_id por device;
/// o salt evita que iPhone e Mac futuros colidam no mesmo diretório.
/// Desvio DELIBERADO do FNV/Math.imul do RN: resume cross-runtime não existe
/// (uploads não migram de app no meio) — não replicar é decisão, não drift.
public func atlasStableUploadKey(identity: String, fileName: String, bytes: Int, installSalt: String) -> String {
    "sw-" + atlasFnv36("\(identity)|\(fileName)|\(bytes)|\(installSalt)") + "-" + String(UInt32(clamping: bytes), radix: 36)
}

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

// MARK: - O engine

public actor AtlasRichInputEngine {
    private let transport: any UploadTransport
    private let limits: AtlasAttachmentLimits
    private let retry: RetryPolicy
    private let installSalt: String

    public init(transport: any UploadTransport,
                limits: AtlasAttachmentLimits = .canonical,
                retry: RetryPolicy = .canonical,
                installSalt: String) {
        self.transport = transport
        self.limits = limits
        self.retry = retry
        self.installSalt = installSalt
    }

    /// Sobe imagens e documentos EM ORDEM (imagens primeiro, como o RN) com
    /// progresso agregado. Falha = throw imediato (sem fallback silencioso);
    /// re-send é responsabilidade do caller com os UploadedAsset já obtidos.
    public func uploadAll(
        images: [AttachmentInput], documents: [AttachmentInput],
        progress: (@Sendable (UploadProgress) -> Void)? = nil
    ) async throws -> (images: [UploadedAsset], documents: [UploadedAsset]) {
        let all = images + documents
        let grandTotal = all.reduce(0) { $0 + $1.bytes.totalBytes }
        var sentSoFar = 0
        var outImages: [UploadedAsset] = []
        var outDocuments: [UploadedAsset] = []

        for (i, input) in all.enumerated() {
            let asset = try await upload(input, fileIndex: i, fileCount: all.count,
                                         baseSentBytes: sentSoFar, grandTotalBytes: grandTotal,
                                         progress: progress)
            sentSoFar += input.bytes.totalBytes
            if i < images.count { outImages.append(asset) } else { outDocuments.append(asset) }
        }
        progress?(UploadProgress(phase: .complete, fileName: "anexos", fileIndex: all.count,
                                 fileCount: all.count, sentBytes: grandTotal,
                                 totalBytes: grandTotal, percent: grandTotal > 0 ? 1 : 0))
        return (outImages, outDocuments)
    }

    /// start → chunks (pulando received_chunks; base64 UMA vez, fora do retry;
    /// SHA-256 incremental sobre TODOS os bytes — os pulados também são lidos
    /// pra hash) → complete (confere sha256 do servidor contra o local).
    public func upload(
        _ input: AttachmentInput, fileIndex: Int = 0, fileCount: Int = 1,
        baseSentBytes: Int = 0, grandTotalBytes: Int? = nil,
        progress: (@Sendable (UploadProgress) -> Void)? = nil
    ) async throws -> UploadedAsset {
        // Falha local barata ANTES do wire — o 422 do server nunca é a 1ª notícia.
        if input.kind == .image, !AtlasAttachmentClassifier.supportedImageMime.contains(input.mimeType.lowercased()) {
            throw RichInputError.unsupportedImageMime(input.mimeType)
        }
        let total = input.bytes.totalBytes
        let maxBytes = input.kind == .image ? limits.maxImageBytes
            : input.kind == .pdf ? limits.maxPdfBytes : limits.maxTextBytes
        if total > maxBytes {
            throw RichInputError.tooLarge(fileName: input.fileName, bytes: total, max: maxBytes)
        }

        let grand = grandTotalBytes ?? total
        func report(_ phase: UploadProgress.Phase, sent: Int) {
            let pct = grand > 0 ? min(1, Double(baseSentBytes + sent) / Double(grand)) : 0
            progress?(UploadProgress(phase: phase, fileName: input.fileName,
                                     fileIndex: fileIndex, fileCount: fileCount,
                                     sentBytes: baseSentBytes + sent, totalBytes: grand, percent: pct))
        }
        report(.starting, sent: 0)

        let key = atlasStableUploadKey(identity: input.identity, fileName: input.fileName,
                                       bytes: total, installSalt: installSalt)
        let started = try await transport.start(ChunkStartRequest(
            clientUploadId: key, kind: input.kind == .image ? "image" : "file",
            fileName: input.fileName, mimeType: input.mimeType,
            totalBytes: total, source: input.source))
        let uploadId = started.upload.id
        let received = Set(started.upload.receivedChunks ?? [])

        let plans = atlasChunkPlans(totalBytes: total, chunkBytes: limits.chunkBytes)
        var hasher = SHA256()
        var sent = 0
        for plan in plans {
            let data = try input.bytes.read(offset: plan.offset, length: plan.length)
            hasher.update(data: data)
            if !received.contains(plan.index) {
                // base64 computada UMA vez, fora do retry (custo de CPU não repete)
                let body = ChunkPartRequest(index: plan.index, totalChunks: plans.count,
                                            offset: plan.offset, bytes: data.count,
                                            chunkBase64: data.base64EncodedString())
                let transport = self.transport
                _ = try await atlasWithRetry(retry) { try await transport.sendChunk(uploadId: uploadId, body) }
            }
            sent += plan.length
            report(.uploading, sent: sent)
        }

        report(.finalizing, sent: total)
        let completed = try await transport.complete(uploadId: uploadId)
        let localSha = hasher.finalize().map { String(format: "%02x", $0) }.joined()
        if let serverSha = completed.upload.sha256, !serverSha.isEmpty, serverSha != localSha {
            throw RichInputError.sha256Mismatch(fileName: input.fileName, local: localSha, server: serverSha)
        }
        return UploadedAsset(uploadedId: completed.upload.id, sha256: localSha, input: input)
    }

    /// Monta os campos do create a partir dos assets subidos. source_hash do
    /// manifest vem PREENCHIDO (sha256 local) — melhoria vs RN/desktop (null).
    public nonisolated func interactionFields(
        images: [UploadedAsset], documents: [UploadedAsset],
        inputText: String,
        textBlocks: [AtlasRichInputPayload.TextBlock] = []
    ) -> RichInputInteractionFields {
        func src(_ a: UploadedAsset) -> RichInputManifestSource {
            .init(id: nil, uri: a.input.identity, fileName: a.input.fileName,
                  mimeType: a.input.mimeType, size: a.input.bytes.totalBytes, source: a.input.source)
        }
        var payload = RichInputPayloadBuilder.build(
            imageAttachments: images.map(src), uploadedImageIds: images.map(\.uploadedId),
            fileAttachments: documents.map(src), uploadedDocumentIds: documents.map(\.uploadedId),
            inputText: inputText, textBlocks: textBlocks)
        // Preenche source_hash (streaming já computou — de graça) nas entries de upload
        let hashes = (images + documents).map(\.sha256)
        for i in payload.sourceManifest.indices where i < hashes.count {
            payload.sourceManifest[i].sourceHash = hashes[i]
        }
        return RichInputInteractionFields(
            uploadedImages: images.map(\.uploadedId),
            uploadedDocuments: documents.map(\.uploadedId),
            richInputPayload: RichInputPayloadBuilder.compact(payload))
    }
}
