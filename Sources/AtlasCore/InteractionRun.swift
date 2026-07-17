import Foundation

/// Um dono por turno. A interface é pequena (`start`, `cancel`); toda a
/// complexidade concorrente fica localizada aqui e é compartilhável por iOS/macOS.
///
/// Helpers extraídos: InteractionRunStream, InteractionRunTypes,
/// InteractionRun+Polling, InteractionRun+Execute.
public actor InteractionRun {
    /// Module-visible so extensions can own poll/recover/execute helpers.
    let transport: any AtlasInteractionTransport
    let reconnectPolicy: AtlasStreamReconnectPolicy
    let pollIntervalNanoseconds: UInt64
    let streamWindowSeconds: Int
    let outbox: InteractionOutbox?

    var activeTask: Task<Void, Never>?
    var pollTask: Task<Void, Never>?
    var activeJobIds: Set<String> = []
    var activeClientId: String?
    var timelineProjection = AtlasAgentTimelineProjection()

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
}
