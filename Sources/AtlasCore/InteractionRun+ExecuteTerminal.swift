import Foundation

/// Terminal resolution after stream/poll — peel de `InteractionRun+Execute`.
extension InteractionRun {
    func resolveInteractionTerminal(
        preparedInput: CreateAiInteractionInput,
        continuation: AsyncThrowingStream<InteractionRunEvent, Error>.Continuation,
        completed: AtlasAiStreamDone?,
        final: AiTraceResponse?,
        traceId: TraceID
    ) async throws {
        if let finalTrace = final?.trace, Self.isSuspended(finalTrace) {
            activeJobIds.removeAll()
            if let clientId = preparedInput.clientId {
                try? await outbox?.remove(clientId: clientId)
            }
            continuation.yield(.suspended(finalTrace))
            continuation.finish()
        } else if let completed, Self.isSuspensionStatus(completed.status) {
            activeJobIds.removeAll()
            if let clientId = preparedInput.clientId {
                try? await outbox?.remove(clientId: clientId)
            }
            continuation.yield(.suspended(final?.trace))
            continuation.finish()
        } else if let completed, Self.isTerminal(completed.status) {
            activeJobIds.removeAll()
            if let clientId = preparedInput.clientId {
                try? await outbox?.remove(clientId: clientId)
            }
            continuation.yield(.completed(done: completed, finalTrace: final?.trace))
            continuation.finish()
        } else if let finalTrace = final?.trace, Self.isTerminal(finalTrace.status) {
            activeJobIds.removeAll()
            if let clientId = preparedInput.clientId {
                try? await outbox?.remove(clientId: clientId)
            }
            continuation.yield(.completed(
                done: AtlasAiStreamDone(traceId: finalTrace.id, status: finalTrace.status, lastSequence: nil),
                finalTrace: finalTrace
            ))
            continuation.finish()
        } else {
            throw AtlasInteractionStreamError.reconnectsExhausted(traceId: traceId.rawValue, lastSequence: 0)
        }
    }
}
