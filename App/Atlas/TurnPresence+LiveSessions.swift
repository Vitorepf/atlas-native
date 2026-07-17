import SwiftUI
import AtlasCore

// LiveSessionSnapshot + publishLiveSessions — peel de TurnPresence.

// LiveSessionSnapshot → LiveSessionSnapshot.swift

@MainActor
extension TurnPresence {
    /// Reconstrói `liveSessions` a partir das entries ongoing. Dedup por
    /// traceId; conversa nova sem thread canônica fica sem navegação.
    func publishLiveSessions() {
        var byTrace: [String: LiveSessionSnapshot] = [:]
        for entry in entries.values where entry.ongoing {
            guard let model = entry.model,
                  let presence = model.currentExecutionPresence,
                  let trace = model.currentExecutionPresenceTraceId else { continue }
            var phase = presence.phaseTitle
            if presence.timing == .running,
               let prog = model.bubbles.last(where: { $0.traceId == trace })?.executionProgress {
                phase = "\(prog.current)/\(prog.total) · \(prog.title)"
            }
            let snap = LiveSessionSnapshot(
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
            byTrace[snap.id] = snap
        }
        liveSessions = byTrace.values.sorted { $0.startedAt < $1.startedAt }
    }
}
