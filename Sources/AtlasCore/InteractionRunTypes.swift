import Foundation

/// Interface completa que uma execução de conversa precisa. O model conhece
/// somente `InteractionRun`; o actor esconde create, polling, SSE e cancel de jobs.
public protocol AtlasInteractionTransport: AtlasAiStreamSource {
    func createInteraction(_ input: CreateAiInteractionInput) async throws -> AiTraceResponse
    func findInteraction(clientId: ClientID) async throws -> AiTraceResponse?
    func interactionSnapshot(traceId: TraceID) async throws -> AiTraceResponse
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
    case execution(InteractionRunExecution)
    case remoteError(JSONValue)
    /// A janela SSE fechou antes de `done` e o stream resumível abriu nova
    /// tentativa com `after=lastSequence`. É um sinal de transporte, não erro
    /// terminal nem razão para duplicar conteúdo.
    case reconnecting(lastSequence: Int, attempt: Int)
    /// O servidor confirmou uma pausa durável (por exemplo, decisão do
    /// operador), portanto o stream pode encerrar sem transformar a pausa em
    /// falha de rede nem reenviar a mesma instrução da outbox.
    case suspended(AtlasAiTrace?)
    case completed(done: AtlasAiStreamDone, finalTrace: AtlasAiTrace?)
}

public struct InteractionRunExecution: Sendable {
    public let trace: AtlasAiTrace
    public let projectedActivities: [AtlasAgentActivity]

    public init(trace: AtlasAiTrace, projectedActivities: [AtlasAgentActivity]) {
        self.trace = trace
        self.projectedActivities = projectedActivities
    }
}

public enum InteractionRunError: Error, CustomStringConvertible, Sendable {
    case alreadyStarted

    public var description: String {
        switch self {
        case .alreadyStarted: return "InteractionRun já iniciado"
        }
    }
}
