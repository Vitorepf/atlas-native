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
    policy: AtlasStreamReconnectPolicy = AtlasStreamReconnectPolicy()
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

/// Interface completa que uma execução de conversa precisa. O model conhece
/// somente `InteractionRun`; o actor esconde create, polling, SSE e cancel de jobs.
public protocol AtlasInteractionTransport: AtlasAiStreamSource {
    func createInteraction(_ input: CreateAiInteractionInput) async throws -> AiTraceResponse
    func findInteraction(clientId: String) async throws -> AiTraceResponse?
    func interactionSnapshot(traceId: String) async throws -> AiTraceResponse
    func cancelInteractionJob(_ jobId: String) async
}

/// Decide se uma criação incerta deve permanecer recuperável. Falhas de rede,
/// timeout, rate limit e servidor podem ter acontecido DEPOIS do commit no
/// backend; 4xx terminais não podem entrar em loop.
public func shouldKeepInteraction(after error: Error) -> Bool {
    if error is AtlasInteractionStreamError { return true }
    if let api = error as? AtlasApiError {
        return api.status == 0 || api.status == 408 || api.status == 429 || api.status >= 500
    }
    let nsError = error as NSError
    if nsError.domain == NSURLErrorDomain { return true }
    return false
}

public enum InteractionRunEvent: Sendable {
    /// A instrução já está na outbox atômica. Follow-ups só podem sair da fila
    /// visível após este recibo, pois um crash posterior continua recuperável.
    case persisted(followUpId: String?)
    case created(AtlasAiTrace)
    case activity(AtlasAgentActivity)
    case content(AtlasAiStreamEvent)
    case execution(AtlasAiTrace)
    case remoteError(JSONValue)
    /// O servidor confirmou uma pausa durável (por exemplo, decisão do
    /// operador), portanto o stream pode encerrar sem transformar a pausa em
    /// falha de rede nem reenviar a mesma instrução da outbox.
    case suspended(AtlasAiTrace?)
    case completed(done: AtlasAiStreamDone, finalTrace: AtlasAiTrace?)
}

public enum InteractionRunError: Error, CustomStringConvertible, Sendable {
    case alreadyStarted

    public var description: String {
        switch self {
        case .alreadyStarted: return "InteractionRun já iniciado"
        }
    }
}

/// Um dono por turno. A interface é pequena (`start`, `cancel`); toda a
/// complexidade concorrente fica localizada aqui e é compartilhável por iOS/macOS.
public actor InteractionRun {
    private let transport: any AtlasInteractionTransport
    private let reconnectPolicy: AtlasStreamReconnectPolicy
    private let pollIntervalNanoseconds: UInt64
    private let streamWindowSeconds: Int
    private let outbox: InteractionOutbox?

    private var activeTask: Task<Void, Never>?
    private var pollTask: Task<Void, Never>?
    private var activeJobIds: Set<String> = []
    private var activeClientId: String?

    public init(
        transport: any AtlasInteractionTransport,
        reconnectPolicy: AtlasStreamReconnectPolicy = AtlasStreamReconnectPolicy(),
        pollIntervalNanoseconds: UInt64 = 1_300_000_000,
        streamWindowSeconds: Int = 120,
        outbox: InteractionOutbox? = nil
    ) {
        self.transport = transport
        self.reconnectPolicy = reconnectPolicy
        self.pollIntervalNanoseconds = pollIntervalNanoseconds
        self.streamWindowSeconds = min(max(streamWindowSeconds, 5), 600)
        self.outbox = outbox
    }

    public func start(
        input: CreateAiInteractionInput,
        followUpId: String? = nil
    ) -> AsyncThrowingStream<InteractionRunEvent, Error> {
        guard activeTask == nil else {
            return AsyncThrowingStream { $0.finish(throwing: InteractionRunError.alreadyStarted) }
        }

        let pair = AsyncThrowingStream<InteractionRunEvent, Error>.makeStream()
        let continuation = pair.continuation
        continuation.onTermination = { [weak self] termination in
            guard case .cancelled = termination else { return }
            Task { await self?.cancel() }
        }
        activeTask = Task { [weak self] in
            await self?.execute(input: input, followUpId: followUpId, continuation: continuation)
        }
        return pair.stream
    }

    public func cancel() async {
        activeTask?.cancel()
        pollTask?.cancel()
        await cancelActiveJobs()
        if let activeClientId { try? await outbox?.remove(clientId: activeClientId) }
    }

    private func execute(
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
            updateActiveJobs(from: created.trace)
            continuation.yield(.created(created.trace))

            let traceId = created.trace.id
            pollTask = Task { [weak self] in
                await self?.poll(traceId: traceId, continuation: continuation)
            }

            let frames = makeAtlasResumableInteractionStream(
                source: transport,
                traceId: traceId,
                timeoutSeconds: streamWindowSeconds,
                policy: reconnectPolicy
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
                continuation.yield(.execution(final.trace))
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
                throw AtlasInteractionStreamError.reconnectsExhausted(traceId: traceId, lastSequence: 0)
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

    private func createOrRecover(
        _ input: CreateAiInteractionInput,
        wasPending: Bool
    ) async throws -> AiTraceResponse {
        if wasPending, let clientId = input.clientId,
           let recovered = try? await transport.findInteraction(clientId: clientId) {
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
                    if let recovered = try await transport.findInteraction(clientId: clientId) {
                        return recovered
                    }
                } catch {
                    lastError = error
                }
            }
            throw lastError
        }
    }

    private func poll(
        traceId: String,
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
                continuation.yield(.execution(response.trace))
                if Self.isTerminal(response.trace.status) { return }
            }
        }
    }

    private func updateActiveJobs(from trace: AtlasAiTrace) {
        activeJobIds = Set((trace.jobs ?? []).compactMap { job in
            job.turnStatus.isActiveWork ? job.id : nil
        })
    }

    private func cancelActiveJobs() async {
        let ids = activeJobIds.sorted()
        activeJobIds.removeAll()
        for id in ids { await transport.cancelInteractionJob(id) }
    }

    private static func isTerminal(_ status: String) -> Bool {
        AtlasTurnStatus(rawValue: status).isTerminal
    }

    private static func isSuspensionStatus(_ status: String) -> Bool {
        AtlasTurnStatus(rawValue: status).isSuspension
    }

    private static func isSuspended(_ trace: AtlasAiTrace) -> Bool {
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

    public func interactionSnapshot(traceId: String) async throws -> AiTraceResponse {
        try await getAiInteraction(traceId)
    }

    public func findInteraction(clientId: String) async throws -> AiTraceResponse? {
        let response = try await listAiInteractions(clientId: clientId, limit: 1)
        return response.traces.first.map(AiTraceResponse.init(trace:))
    }

    public func cancelInteractionJob(_ jobId: String) async {
        _ = try? await cancelAiJob(jobId)
    }
}
