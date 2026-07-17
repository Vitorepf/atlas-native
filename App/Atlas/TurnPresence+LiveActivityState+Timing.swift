import Foundation
import AtlasCore

// Relógio/pausa do ContentState — peel de TurnPresence+LiveActivityState.

@MainActor
extension TurnPresence {
    static func timingAnchor(
        entry: Entry,
        presence p: AtlasExecutionPresence?,
        finished: Bool
    ) -> (started: Date, paused: Bool?, pausedDisplay: String?) {
        var started = entry.startedAt
        var paused: Bool? = nil
        var pausedDisplay: String? = nil
        if let p {
            if let since = p.runningSince {
                started = since.addingTimeInterval(-Double(p.elapsedActiveMilliseconds ?? 0) / 1000)
            } else if p.isTimerPaused {
                paused = true
                pausedDisplay = p.elapsedActiveMilliseconds.map(clock)
            }
            if finished, let ms = p.elapsedActiveMilliseconds {
                pausedDisplay = clock(ms)
            }
        }
        if started > Date() { started = Date() }
        return (started, paused, pausedDisplay)
    }
}
