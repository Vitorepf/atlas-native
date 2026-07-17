import Foundation
import CryptoKit

extension AtlasRichInputEngine {
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
}
