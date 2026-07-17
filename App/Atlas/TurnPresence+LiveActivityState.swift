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
        var started = entry.startedAt
        var paused: Bool? = nil
        var pausedDisplay: String? = nil
        if let p {
            if let since = p.runningSince {
                started = since.addingTimeInterval(-Double(p.elapsedActiveMilliseconds ?? 0) / 1000)
            } else if p.isTimerPaused {
                paused = true
                pausedDisplay = p.elapsedActiveMilliseconds.map(Self.clock)
            }
            if finished, let ms = p.elapsedActiveMilliseconds {
                pausedDisplay = Self.clock(ms)   // congela o total ativo no fim
            }
        }
        if started > Date() { started = Date() }
        return AtlasTurnAttributes.ContentState(
            phaseTitle: phaseOverride ?? p?.phaseTitle ?? (finished ? "resposta pronta" : "Executando"),
            startedAt: started,
            finished: finished,
            activeSessions: max(finished ? 0 : 1, activeCount),
            paused: paused,
            pausedDisplay: pausedDisplay,
            progressCurrent: progress?.current,
            progressTotal: progress?.total,
            queuedCount: entry.model?.queuedMessages.count)
    }

    static func clock(_ ms: Int) -> String {
        let s = ms / 1000
        return s >= 3600 ? String(format: "%d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
                         : String(format: "%d:%02d", s / 60, s % 60)
    }
}
