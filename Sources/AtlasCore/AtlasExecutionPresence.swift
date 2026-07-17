import Foundation

/// Projeção mínima para superfícies de presença do iOS. Ela traduz somente o
/// contrato tipado ou a atividade pública já sanitizada; nunca usa texto de
/// provider para inventar uma fase. A casca recebe também se o tempo deve
/// seguir ou ficar pausado, sem reconstruir essa regra em cada superfície.
public struct AtlasExecutionPresence: Sendable, Equatable {
    public enum Timing: Sendable, Equatable {
        case running
        case paused
        case finished
    }

    public let phaseTitle: String
    public let timing: Timing
    /// Relógio provider-safe acumulado pelo servidor. `nil` nos traces
    /// legados, caso em que a superfície não pode fingir que conhece pausas.
    public let timer: AtlasExecutionPresentationState.Timer?
    /// `nil` para estados legados e para execução corrente. Uma pausa com
    /// timestamp declarado permite à casca congelar o mesmo valor no app,
    /// Lock Screen e Dynamic Island.
    public let pauseTimestamp: Date?

    public init?(
        isExecuting: Bool,
        presentationState: AtlasExecutionPresentationState?,
        currentActivity: AtlasAgentActivity?
    ) {
        if let state = presentationState {
            timer = state.timer
            switch state.kind {
            case .attentionRequired:
                phaseTitle = "Aguardando decisão"
                timing = .paused
                pauseTimestamp = state.timer?.pausedAt ?? AtlasTime.date(state.pausedAt)
                return
            case .awaitingExternal:
                phaseTitle = "Aguardando sistema externo"
                timing = .paused
                pauseTimestamp = state.timer?.pausedAt ?? AtlasTime.date(state.pausedAt)
                return
            case .recovering:
                phaseTitle = "Reconectando"
                timing = .running
                pauseTimestamp = nil
                return
            case .replanning:
                phaseTitle = "Replanejando"
                timing = .running
                pauseTimestamp = nil
                return
            case .failed:
                phaseTitle = "Falhou"
                timing = .finished
                pauseTimestamp = nil
                return
            case .completed:
                phaseTitle = "Concluído"
                timing = .finished
                pauseTimestamp = nil
                return
            }
        }

        guard isExecuting else { return nil }
        phaseTitle = currentActivity?.title ?? "Executando"
        timing = .running
        timer = nil
        pauseTimestamp = nil
    }

    public var isTimerPaused: Bool { timing == .paused }

    public var elapsedActiveMilliseconds: Int? { timer?.elapsedActiveMilliseconds }
    public var runningSince: Date? { timer?.runningSince }

    /// Uma pausa confirmada pelo servidor continua sendo uma execução em
    /// presença, mesmo depois que o stream daquela tentativa foi fechado.
    public var isOngoing: Bool { timing != .finished }
}

public extension AtlasAiTrace {
    /// O ledger é cronológico e sobrevive a SSE, polling e relaunch. Um evento
    /// posterior prevalece sobre o snapshot do trace para a casca nunca voltar
    /// a mostrar um estado já superado após reconectar.
    var executionPresentationState: AtlasExecutionPresentationState? {
        for event in (streamEvents ?? []).sorted(by: { $0.sequence > $1.sequence }) {
            if let state = AtlasExecutionPresentationState(metadata: event.metadata) {
                return state
            }
        }
        return AtlasExecutionPresentationState(metadata: metadata)
    }
}
