import SwiftUI
import AtlasCore

// Loop de snapshots — peel de TurnPresence+LiveSessions.

@MainActor
extension TurnPresence {
    func liveSessionSnapshot(from entry: Entry) -> LiveSessionSnapshot? {
        guard let model = entry.model,
              let presence = model.currentExecutionPresence,
              let trace = model.currentExecutionPresenceTraceId else { return nil }
        var phase = presence.phaseTitle
        if presence.timing == .running,
           let prog = model.bubbles.last(where: { $0.traceId == trace })?.executionProgress {
            phase = "\(prog.current)/\(prog.total) · \(prog.title)"
        }
        return LiveSessionSnapshot(
            id: trace.rawValue,
            threadId: entry.threadId ?? model.threadId,
            title: entry.threadTitle,
            phaseTitle: phase,
            timing: presence.timing,
            elapsedActiveMs: presence.elapsedActiveMilliseconds,
            runningSince: presence.runningSince,
            pauseTimestamp: presence.pauseTimestamp,
            startedAt: entry.startedAt,
            isRemote: false
        )
    }
}
