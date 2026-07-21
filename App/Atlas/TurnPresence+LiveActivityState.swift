import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit
#endif

// ContentState + relógio — peel de TurnPresence+LiveActivity.

@MainActor
extension TurnPresence {
    /// ContentState a partir da presença tipada — o ÚNICO relógio permitido:
    /// com timer do servidor, o timer nativo parte de (runningSince − ativo
    /// acumulado) e mostra exatamente o tempo ATIVO; pausado congela o
    /// acumulado em texto; trace legado cai na base local sem fingir pausas.
    func contentState(_ entry: Entry, presence p: AtlasExecutionPresence?,
                      finished: Bool, phaseOverride: String? = nil,
                      progress: AtlasExecutionPlan.Progress? = nil)
        -> AtlasTurnAttributes.ContentState {
        let timing = Self.timingAnchor(entry: entry, presence: p, finished: finished)
        return AtlasTurnAttributes.ContentState(
            phaseTitle: phaseOverride ?? p?.phaseTitle ?? (finished ? "resposta pronta" : "Executando"),
            startedAt: timing.started,
            finished: finished,
            activeSessions: max(finished ? 0 : 1, activeCount),
            paused: timing.paused,
            pausedDisplay: timing.pausedDisplay,
            progressCurrent: progress?.current,
            progressTotal: progress?.total,
            queuedCount: entry.model?.queuedMessages.count)
    }
}
