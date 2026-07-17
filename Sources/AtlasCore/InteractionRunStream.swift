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

/// Transforma conexões SSE descartáveis num stream resumível profundo:
/// mantém cursor monotônico, filtra frames de outro trace, não reemite sequência
/// já entregue e só conclui depois de `done`.
public func makeAtlasResumableInteractionStream(
    source: any AtlasAiStreamSource,
    traceId: String,
    after: Int = 0,
    timeoutSeconds: Int = 120,
    policy: AtlasStreamReconnectPolicy = AtlasStreamReconnectPolicy(),
    onReconnect: (@Sendable (_ lastSequence: Int, _ attempt: Int) -> Void)? = nil
) -> AsyncThrowingStream<AtlasAiStreamFrame, Error> {
    AsyncThrowingStream { continuation in
        let task = Task {
            var lastSequence = max(0, after)
            var completed = false

            do {
                attempts: for attempt in 0...policy.maxReconnects {
                    try Task.checkCancellation()
                    let stream = try await source.openInteractionStreamOnce(
                        traceId: traceId,
                        after: lastSequence,
                        timeoutSeconds: min(max(timeoutSeconds, 5), 600)
                    )

                    frames: for try await frame in stream {
                        try Task.checkCancellation()
                        switch frame {
                        case .event(let event):
                            guard event.traceId == traceId, event.sequence > lastSequence else { continue }
                            lastSequence = event.sequence
                            continuation.yield(frame)
                        case .done(let done):
                            guard done.traceId == traceId else { continue }
                            if let sequence = done.lastSequence {
                                lastSequence = max(lastSequence, sequence)
                            }
                            continuation.yield(frame)
                            completed = true
                            break frames
                        case .error, .ignored:
                            continuation.yield(frame)
                        }
                    }

                    if completed { break attempts }
                    if attempt < policy.maxReconnects {
                        onReconnect?(lastSequence, attempt + 1)
                        try await Task.sleep(nanoseconds: policy.delayNanoseconds(afterAttempt: attempt))
                    }
                }

                guard completed else {
                    throw AtlasInteractionStreamError.reconnectsExhausted(
                        traceId: traceId,
                        lastSequence: lastSequence
                    )
                }
                continuation.finish()
            } catch is CancellationError {
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}
