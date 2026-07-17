import SwiftUI
import AtlasCore

extension AtlasSession {
    func setLiveSessionsPollingActive(_ active: Bool) {
        guard active, hasToken else {
            liveSessionsPollingTask?.cancel()
            liveSessionsPollingTask = nil
            remoteLiveSessions = []
            AtlasNativeSnapshotWriter.shared.recordRemoteLiveSessions([])
            return
        }
        guard liveSessionsPollingTask == nil else { return }
        liveSessionsPollingTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                await self?.refreshRemoteLiveSessions()
                do {
                    try await Task.sleep(nanoseconds: 30_000_000_000)
                } catch {
                    break
                }
            }
        }
    }

    fileprivate func refreshRemoteLiveSessions() async {
        do {
            let response = try await client.getAiSessionsLive(installation: AtlasInstallationIdentity.id)
            remoteLiveSessions = response.sessions.enumerated().map { index, session in
                LiveSessionSnapshot(remote: session, index: index)
            }
            AtlasNativeSnapshotWriter.shared.recordRemoteLiveSessions(remoteLiveSessions)
        } catch {
            remoteLiveSessions = []
            AtlasNativeSnapshotWriter.shared.recordRemoteLiveSessions([])
        }
    }
}

private extension LiveSessionSnapshot {
    init(remote session: AtlasAiLiveSession, index: Int) {
        let threadId = session.threadId
        self.init(
            id: threadId.map { "remote-thread:\($0.rawValue)" } ?? "remote-session:\(index)",
            threadId: threadId,
            title: session.title?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty ?? "Sessão Atlas",
            phaseTitle: session.phaseTitle?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty ?? "Executando",
            timing: session.timing.presenceTiming,
            elapsedActiveMs: session.elapsedActiveMs,
            runningSince: session.runningSinceDate,
            pauseTimestamp: nil,
            startedAt: .now,
            isRemote: true
        )
    }
}

private extension Optional where Wrapped == AtlasAiLiveSessionTiming {
    var presenceTiming: AtlasExecutionPresence.Timing {
        switch self {
        case .running, nil: return .running
        case .paused: return .paused
        case .finished: return .finished
        }
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
