import Foundation

/// Stream resumível — peel de InteractionRunStream.

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
