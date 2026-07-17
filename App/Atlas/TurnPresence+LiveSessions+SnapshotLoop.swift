import SwiftUI
import AtlasCore

// Loop de snapshots — peel de TurnPresence+LiveSessions.
// Phase → TurnPresence+LiveSessions+SnapshotPhase.swift

@MainActor
extension TurnPresence {
    func liveSessionSnapshot(from entry: Entry) -> LiveSessionSnapshot? {
        guard let model = entry.model,
              let presence = model.currentExecutionPresence,
              let trace = model.currentExecutionPresenceTraceId else { return nil }
        return LiveSessionSnapshot(
            id: trace.rawValue,
            threadId: entry.threadId ?? model.threadId,
            title: entry.threadTitle,
            phaseTitle: liveSessionPhaseTitle(model: model, trace: trace, presence: presence),
            timing: presence.timing,
            elapsedActiveMs: presence.elapsedActiveMilliseconds,
            runningSince: presence.runningSince,
            pauseTimestamp: presence.pauseTimestamp,
            startedAt: entry.startedAt,
            isRemote: false
        )
    }
}
