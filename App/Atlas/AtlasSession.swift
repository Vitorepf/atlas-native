import AtlasCore
import Foundation
import Network
import SwiftUI

// IDLE-COMPRESS AtlasSession fused

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

extension AtlasSession {
    static func nightlyProposalMutedUntil(now: Date = .init()) -> Date? {
        guard let until = UserDefaults.standard.object(forKey: nightlyProposalMuteKey) as? Date else {
            return nil
        }
        if until > now { return until }
        UserDefaults.standard.removeObject(forKey: nightlyProposalMuteKey)
        return nil
    }

    @discardableResult
    static func muteNightlyProposal(days: Int, now: Date = .init()) -> Date {
        let days = max(1, days)
        let until = Calendar.current.date(byAdding: .day, value: days, to: now)
            ?? now.addingTimeInterval(Double(days) * 86_400)
        UserDefaults.standard.set(until, forKey: nightlyProposalMuteKey)
        return until
    }

    static func clearExpiredNightlyProposalMute(now: Date = .init()) -> Date? {
        nightlyProposalMutedUntil(now: now)
    }

    static func clearNightlyProposalMute() {
        UserDefaults.standard.removeObject(forKey: nightlyProposalMuteKey)
    }
}

extension AtlasSession {
    static let nightlyDismissStreakKey = "atlas.nightlyProposal.dismissStreak"
    static let nightlyAcceptTotalKey = "atlas.nightlyProposal.acceptedTotal"
    static let nightlyDismissTotalKey = "atlas.nightlyProposal.dismissedTotal"
    static let nightlyAutoPausedKey = "atlas.nightlyProposal.autoPaused"

    @discardableResult
    static func recordNightlyProposalDismissal() -> Int {
        let defaults = UserDefaults.standard
        let streak = defaults.integer(forKey: nightlyDismissStreakKey) + 1
        defaults.set(streak, forKey: nightlyDismissStreakKey)
        defaults.set(defaults.integer(forKey: nightlyDismissTotalKey) + 1, forKey: nightlyDismissTotalKey)
        return streak
    }

    static let nightlyAcceptDelaysKey = "atlas.nightlyProposal.acceptDelays"

    static func recordNightlyProposalAccept(delayMinutes: Int? = nil) {
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: nightlyDismissStreakKey)
        defaults.set(defaults.integer(forKey: nightlyAcceptTotalKey) + 1, forKey: nightlyAcceptTotalKey)
        if let delayMinutes {
            var delays = defaults.array(forKey: nightlyAcceptDelaysKey) as? [Int] ?? []
            delays.append(min(max(delayMinutes, 0), 180))
            defaults.set(Array(delays.suffix(5)), forKey: nightlyAcceptDelaysKey)
        }
    }

    static func nightlyProposalAdjustmentMinutes() -> Int {
        let delays = (UserDefaults.standard.array(forKey: nightlyAcceptDelaysKey) as? [Int] ?? []).sorted()
        guard delays.count >= 2 else { return 0 }
        let median = delays[delays.count / 2]
        let rounded = (min(median, 60) / 5) * 5
        return rounded >= 5 ? rounded : 0
    }

    static func resetNightlyProposalStreak() {
        UserDefaults.standard.set(0, forKey: nightlyDismissStreakKey)
    }

    static func nightlyProposalScore() -> (accepted: Int, dismissed: Int) {
        let defaults = UserDefaults.standard
        return (defaults.integer(forKey: nightlyAcceptTotalKey),
                defaults.integer(forKey: nightlyDismissTotalKey))
    }

    static func setNightlyProposalAutoPaused(_ paused: Bool) {
        UserDefaults.standard.set(paused, forKey: nightlyAutoPausedKey)
    }

    static func nightlyProposalAutoPaused() -> Bool {
        UserDefaults.standard.bool(forKey: nightlyAutoPausedKey)
    }
}
