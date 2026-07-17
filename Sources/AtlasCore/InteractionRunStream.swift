import Foundation

/// Uma conexão SSE isolada. O adapter real é `AtlasClient`; checks usam uma
/// fonte roteirizada para provar reconnect, cursor e deduplicação sem rede.
public protocol AtlasAiStreamSource: Sendable {
    func openInteractionStreamOnce(
        traceId: String,
        after: Int,
        timeoutSeconds: Int
    ) async throws -> AsyncThrowingStream<AtlasAiStreamFrame, Error>
}

public struct AtlasStreamReconnectPolicy: Sendable {
    public let maxReconnects: Int
    public let baseDelayMilliseconds: Int
    public let maximumDelayMilliseconds: Int

    public init(
        maxReconnects: Int = 4,
        baseDelayMilliseconds: Int = 500,
        maximumDelayMilliseconds: Int = 2_000
    ) {
        self.maxReconnects = max(0, maxReconnects)
        self.baseDelayMilliseconds = max(0, baseDelayMilliseconds)
        self.maximumDelayMilliseconds = max(0, maximumDelayMilliseconds)
    }

    func delayNanoseconds(afterAttempt attempt: Int) -> UInt64 {
        let milliseconds = min(baseDelayMilliseconds * (attempt + 1), maximumDelayMilliseconds)
        return UInt64(milliseconds) * 1_000_000
    }
}

public enum AtlasInteractionStreamError: Error, CustomStringConvertible, Sendable {
    case reconnectsExhausted(traceId: String, lastSequence: Int)

    public var description: String {
        switch self {
        case .reconnectsExhausted(_, let lastSequence):
            return "Atlas stream incompleto após reconexões (último evento=\(lastSequence)); o turno continua recuperável"
        }
    }
}
