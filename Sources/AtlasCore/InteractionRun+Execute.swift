import Foundation

/// Turn execution loop — kept out of the main actor file so the owner stays
/// under the anti-inchaço régua (~300).
extension InteractionRun {
    func execute(
        input: CreateAiInteractionInput,
        followUpId: String?,
        continuation: AsyncThrowingStream<InteractionRunEvent, Error>.Continuation
    ) async {
        var preparedInput = input
        do {
            let wasPending: Bool
            if let outbox {
                let prepared = try await outbox.prepare(input, followUpId: followUpId)
                preparedInput = prepared.input
                wasPending = prepared.wasPending
                continuation.yield(.persisted(followUpId: prepared.followUpId))
            } else {
                wasPending = false
            }
            activeClientId = preparedInput.clientId

            let created = try await createOrRecover(preparedInput, wasPending: wasPending)
            timelineProjection = AtlasAgentTimelineProjection()
            updateActiveJobs(from: created.trace)
            continuation.yield(.created(created.trace))

            let traceId = TraceID(created.trace.id)
            pollTask = Task { [weak self] in
                await self?.poll(traceId: traceId, continuation: continuation)
            }

            let frames = makeAtlasResumableInteractionStream(
                source: transport,
                traceId: traceId.rawValue,
                timeoutSeconds: streamWindowSeconds,
                policy: reconnectPolicy,
                onReconnect: { lastSequence, attempt in
                    continuation.yield(.reconnecting(lastSequence: lastSequence, attempt: attempt))
                }
            )
            var completed: AtlasAiStreamDone?
            do {
                stream: for try await frame in frames {
                    try Task.checkCancellation()
                    switch frame {
                    case .event(let event):
                        if let activity = atlasAgentActivity(from: event) {
                            continuation.yield(.activity(activity))
                        }
                        continuation.yield(.content(event))
                    case .done(let done):
                        completed = done
                        break stream
                    case .error(let payload): continuation.yield(.remoteError(payload))
                    case .ignored: break
                    }
                }
            } catch is AtlasInteractionStreamError {
                // Um snapshot posterior pode provar que o servidor chegou a
                // um estado estável enquanto a conexão SSE caiu.
            }
            try Task.checkCancellation()

            pollTask?.cancel()
            let final = try? await transport.interactionSnapshot(traceId: traceId)
            if let final {
                updateActiveJobs(from: final.trace)
                continuation.yield(.execution(projectedExecution(from: final.trace)))
            }
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
        } catch is CancellationError {
            await cancelActiveJobs()
            if let clientId = preparedInput.clientId {
                try? await outbox?.remove(clientId: clientId)
            }
            continuation.finish()
        } catch {
            pollTask?.cancel()
            if !shouldKeepInteraction(after: error), let clientId = preparedInput.clientId {
                try? await outbox?.remove(clientId: clientId)
            }
            continuation.finish(throwing: error)
        }

        pollTask = nil
        activeTask = nil
        activeClientId = nil
    }
}
