import Foundation

/// Poll/recover/projection helpers for `InteractionRun`. Kept out of the main
/// actor file so the turn owner stays under the anti-inchaço régua (~400).
extension InteractionRun {
    func createOrRecover(
        _ input: CreateAiInteractionInput,
        wasPending: Bool
    ) async throws -> AiTraceResponse {
        if wasPending, let clientId = input.clientId,
           let recovered = try? await transport.findInteraction(clientId: ClientID(clientId)) {
            return recovered
        }
        do {
            return try await transport.createInteraction(input)
        } catch {
            guard shouldKeepInteraction(after: error),
                  let clientId = input.clientId,
                  UUID(uuidString: clientId) != nil else {
                throw error
            }

            var lastError = error
            for attempt in 0..<5 {
                if attempt > 0 {
                    do {
                        try await Task.sleep(nanoseconds: UInt64(250 * (1 << (attempt - 1))) * 1_000_000)
                    } catch {
                        throw error
                    }
                }
                do {
                    if let recovered = try await transport.findInteraction(clientId: ClientID(clientId)) {
                        return recovered
                    }
                } catch {
                    lastError = error
                }
            }
            throw lastError
        }
    }

    func poll(
        traceId: TraceID,
        continuation: AsyncThrowingStream<InteractionRunEvent, Error>.Continuation
    ) async {
        while !Task.isCancelled {
            do {
                try await Task.sleep(nanoseconds: pollIntervalNanoseconds)
            } catch {
                return
            }
            if let response = try? await transport.interactionSnapshot(traceId: traceId) {
                guard !Task.isCancelled else { return }
                updateActiveJobs(from: response.trace)
                continuation.yield(.execution(projectedExecution(from: response.trace)))
                if Self.isTerminal(response.trace.status) { return }
            }
        }
    }

    func projectedExecution(from trace: AtlasAiTrace) -> InteractionRunExecution {
        let projectedActivities = timelineProjection.merge(events: trace.streamEvents ?? [], limit: .max)
        return InteractionRunExecution(trace: trace, projectedActivities: projectedActivities)
    }

    func updateActiveJobs(from trace: AtlasAiTrace) {
        activeJobIds = Set((trace.jobs ?? []).compactMap { job in
            job.turnStatus.isActiveWork ? job.id : nil
        })
    }

    func cancelActiveJobs() async {
        let ids = activeJobIds.sorted()
        activeJobIds.removeAll()
        for id in ids { await transport.cancelInteractionJob(id) }
    }

    static func isTerminal(_ status: String) -> Bool {
        AtlasTurnStatus(rawValue: status).isTerminal
    }

    static func isSuspensionStatus(_ status: String) -> Bool {
        AtlasTurnStatus(rawValue: status).isSuspension
    }

    static func isSuspended(_ trace: AtlasAiTrace) -> Bool {
        if trace.turnStatus.isSuspension { return true }
        switch trace.executionPresentationState?.kind {
        case .attentionRequired, .awaitingExternal:
            return true
        default:
            return false
        }
    }
}

extension AtlasClient: AtlasInteractionTransport {
    public func createInteraction(_ input: CreateAiInteractionInput) async throws -> AiTraceResponse {
        try await createAiInteraction(input)
    }

    public func interactionSnapshot(traceId: TraceID) async throws -> AiTraceResponse {
        try await getAiInteraction(traceId)
    }

    public func findInteraction(clientId: ClientID) async throws -> AiTraceResponse? {
        let response = try await listAiInteractions(clientId: clientId.rawValue, limit: 1)
        return response.traces.first.map(AiTraceResponse.init(trace:))
    }

    public func cancelInteractionJob(_ jobId: String) async {
        _ = try? await cancelAiJob(jobId)
    }
}
