import SwiftUI
import AtlasCore

// LiveSessionSnapshot + publishLiveSessions — peel de TurnPresence.

/// Snapshot de uma sessão viva observada neste processo — a home lê isto
/// para virar cockpit (V1). Zero rede; só o que o TurnPresence já sabe.
struct LiveSessionSnapshot: Identifiable, Equatable {
    let id: String            // traceId corrente (estável por execução)
    let threadId: ThreadID?   // para Route.thread; nil se conversa nova local
    let title: String
    let phaseTitle: String
    let timing: AtlasExecutionPresence.Timing
    let elapsedActiveMs: Int?
    let runningSince: Date?
    let pauseTimestamp: Date?
    /// 1ª observação local — só ordenação; nunca exibido como duração.
    let startedAt: Date
    let isRemote: Bool
}

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
