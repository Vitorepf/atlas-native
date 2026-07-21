import AtlasCore
import Foundation
import Network
import SwiftUI

// IDLE-COMPRESS AtlasSession fused

// --- AtlasSession+LiveSessions.swift ---
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

// --- AtlasSession+Nightly.swift ---
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

// --- AtlasSession+NightlyDecisions.swift ---
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

// --- AtlasSession+RecentWorkspaces.swift ---
extension AtlasSession {
    func recentWorkspaces(_ limit: Int) -> [Workspace] {
        let ranked = workspaces.sorted { a, b in
            (latestThreadActivity(inWorkspace: a.id) ?? "")
                > (latestThreadActivity(inWorkspace: b.id) ?? "")
        }
        return Array(ranked.prefix(limit))
    }

    private func latestThreadActivity(inWorkspace key: String) -> String? {
        threads(inWorkspace: key).map(\.updatedAt).max()
    }
}

// --- AtlasSession+Workspaces.swift ---
extension AtlasSession {
    var workspaces: [Workspace] {
        var groups: [String: (name: String, count: Int)] = [:]
        for t in threads {
            guard let w = t.workspace, !w.isEmpty else { continue }
            let base = (w as NSString).lastPathComponent
            let key = base.lowercased()
            var g = groups[key] ?? (name: base, count: 0)
            g.count += 1
            groups[key] = g
        }
        return groups
            .map { Workspace(id: $0.key, name: $0.value.name, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    func workspaceFullPath(forKey key: String) -> String? {
        threads.first {
            guard let w = $0.workspace, !w.isEmpty else { return false }
            return (w as NSString).lastPathComponent.lowercased() == key
        }?.workspace
    }

    func threads(inWorkspace key: String?) -> [AtlasAiThread] {
        guard let key else { return threads }
        return threads.filter {
            guard let w = $0.workspace, !w.isEmpty else { return false }
            return (w as NSString).lastPathComponent.lowercased() == key
        }
    }
}

// --- AtlasSession.swift ---
@MainActor
@Observable
final class AtlasSession {
    static let rhythm = AtlasDayRhythm()
    static let nightlyProposalMuteKey = "atlas.nightlyProposal.mutedUntil"
    private static let auditModeKey = "atlas.auditMode.enabled"

    var phase: LoadPhase = .idle
    var failureKind: AtlasNetworkFailureKind?
    var threads: [AtlasAiThread] = []
    var remoteLiveSessions: [LiveSessionSnapshot] = []  // set interno: família de peels
    var auditModeEnabled: Bool {
        didSet { UserDefaults.standard.set(auditModeEnabled, forKey: Self.auditModeKey) }
    }

    let host: String
    let hasToken: Bool
    let client: AtlasClient
    let autonomos: AutonomosModel
    let arena: ArenaModel
    @ObservationIgnored var liveSessionsPollingTask: Task<Void, Never>?
    @ObservationIgnored private let pathMonitor = NWPathMonitor()
    @ObservationIgnored private let pathMonitorQueue = DispatchQueue(label: "atlas.native.path-monitor")
    @ObservationIgnored private var sawPathDown = false
    @ObservationIgnored private var reconnectAfterRestoreArmed = true

    init() {
        let info = Bundle.main.infoDictionary ?? [:]
        let host = (info["ATLAS_HOST"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "127.0.0.1"
        let port = Int((info["ATLAS_PORT"] as? String) ?? "3737") ?? 3737
        let token = AtlasTokenStore.resolve(configuredToken: (info["ATLAS_TOKEN"] as? String) ?? "")
        self.host = host
        self.hasToken = !token.isEmpty
        let client = AtlasClient(config: AtlasConfig(host: host, port: port, token: token))
        self.client = client
        self.autonomos = AutonomosModel(client: client)
        self.arena = ArenaModel(client: client)
        self.auditModeEnabled = UserDefaults.standard.bool(forKey: Self.auditModeKey)
        startPathMonitor()
    }

    deinit {
        pathMonitor.cancel()
    }

    func loadThreads() async {
        phase = .loading
        failureKind = nil
        do {
            let response = try await client.listAiThreads(light: true, limit: 100)
            threads = response.threads
            phase = .loaded
            Task { await Self.rhythm.recordActivity(workspace: nil) }
        } catch {
            failureKind = atlasNetworkFailureKind(for: error)
            phase = .failed(String(describing: error))
        }
    }

    private func startPathMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self else { return }
                await self.client.setNetworkPathCost(.init(
                    isExpensive: path.isExpensive,
                    isConstrained: path.isConstrained
                ))
                if path.status == .satisfied {
                    if sawPathDown, reconnectAfterRestoreArmed, case .failed = phase {
                        reconnectAfterRestoreArmed = false
                        await loadThreads()
                    }
                    sawPathDown = false
                } else {
                    sawPathDown = true
                    reconnectAfterRestoreArmed = true
                }
            }
        }
        pathMonitor.start(queue: pathMonitorQueue)
    }
}
