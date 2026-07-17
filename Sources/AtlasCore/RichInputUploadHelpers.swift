import Foundation

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
