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
//
// Tipos/helpers extraídos: RichInputByteSource, RichInputUploadHelpers,
// RichInputEngineTypes; upload loop em AtlasRichInputEngine+Upload.

// MARK: - Seam 2 · transporte (3 endpoints, nada mais)

public protocol UploadTransport: Sendable {
    func start(_ request: ChunkStartRequest) async throws -> ChunkStartResponse
    func sendChunk(uploadId: String, _ body: ChunkPartRequest) async throws -> ChunkPartResponse
    func complete(uploadId: String) async throws -> ChunkCompleteResponse
}

// MARK: - O engine

public actor AtlasRichInputEngine {
    let transport: any UploadTransport
    let limits: AtlasAttachmentLimits
    let retry: RetryPolicy
    let installSalt: String

    public init(transport: any UploadTransport,
                limits: AtlasAttachmentLimits = .canonical,
                retry: RetryPolicy = .canonical,
                installSalt: String) {
        self.transport = transport
        self.limits = limits
        self.retry = retry
        self.installSalt = installSalt
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
