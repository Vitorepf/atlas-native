import Foundation

// Rich Input · L0→L2 — o AtlasClient como UploadTransport real.
// Timeouts dimensionados pelo wire de verdade: chunk de 1.5MB vira ~2MB de
// JSON (base64 +33%) — 45s aguenta rede ruim; complete remonta até 20MB em
// disco no servidor — 60s. O default de 15s do request comum estoura ambos.

private struct EmptyBody: Encodable {}

extension AtlasClient: UploadTransport {
    public func start(_ request: ChunkStartRequest) async throws -> ChunkStartResponse {
        try await post("/ai/uploads/chunks/start", body: request, timeout: 30)
    }

    public func sendChunk(uploadId: String, _ body: ChunkPartRequest) async throws -> ChunkPartResponse {
        try await post("/ai/uploads/chunks/\(pathEncoded(uploadId))/chunk", body: body, timeout: 45)
    }

    public func complete(uploadId: String) async throws -> ChunkCompleteResponse {
        try await post("/ai/uploads/chunks/\(pathEncoded(uploadId))/complete", body: EmptyBody(), timeout: 60)
    }

    private func pathEncoded(_ s: String) -> String {
        s.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? s
    }
}
