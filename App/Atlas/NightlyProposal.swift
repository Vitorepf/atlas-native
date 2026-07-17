import SwiftUI
import UserNotifications

@MainActor
@Observable
final class NightlyProposalController: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NightlyProposalController()

    private let nightlyIdentifier = "atlas.nightly"
    let morningIdentifier = "atlas.morning"
    @ObservationIgnored let center = UNUserNotificationCenter.current()
    @ObservationIgnored var openAutonomos: (() -> Void)?
    @ObservationIgnored var immediateNightlyDateKey: String?

    private(set) var pendingProposal: ProposalPayload?
    private(set) var mutedUntil: Date?

    /// Casca: silêncio total enquanto mute ativo — sem card, sem placeholder, sem toast.
    var isProposalMuted: Bool { isMuted() }

    private override init() {
        super.init()
        mutedUntil = AtlasSession.nightlyProposalMutedUntil()
    }

    func installAsNotificationDelegate() {
        center.delegate = self
    }

    func registerOpenAutonomos(_ handler: @escaping () -> Void) { openAutonomos = handler }

    func scheduleForBackground(now: Date = .init()) async {
        guard !isMuted(now: now) else {
            center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
            return
        }
        let windows = await AtlasSession.rhythm.windows(minimumDays: 4, now: now)
        guard let dayEnd = windows.dayEnd else {
            center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier, morningIdentifier])
            return
        }

        let summary = await AtlasSession.rhythm.todaySummary(now: now)
        guard !summary.workspaces.isEmpty else {
            center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
            return
        }
        guard await canScheduleNotifications() else { return }

        let content = UNMutableNotificationContent()
        content.title = "A frota pode trabalhar esta noite"
        content.body = "Hoje você mexeu em \(summary.workspaces.joined(separator: ", ")). Quer pôr os Autônomos nisso enquanto descansa?"
        content.sound = .default
        content.userInfo = [
            "atlas.route": "autonomos-nightly",
            "atlas.workspaces": summary.workspaces,
        ]

        center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
        let request = UNNotificationRequest(
            identifier: nightlyIdentifier,
            content: content,
            trigger: nightlyTrigger(dayEnd: dayEnd, now: now)
        )
        try? await center.add(request)
    }

    func dismissProposal() { pendingProposal = nil }

    func muteProposal(days: Int, now: Date = .init()) {
        let days = max(1, days)
        let until = AtlasSession.muteNightlyProposal(days: days, now: now)
        mutedUntil = until
        pendingProposal = nil
        center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
    }

    func accept(_ proposal: ProposalPayload) async {
        await scheduleMorning(after: proposal)
        pendingProposal = nil
    }

    #if DEBUG
    func installDemoIfRequested(arguments: [String] = ProcessInfo.processInfo.arguments) {
        guard arguments.contains("-atlas.nightly.demo") else { return }
        pendingProposal = ProposalPayload(workspaces: ["atlas-native"])
    }
    #endif

    func isMuted(now: Date = .init()) -> Bool {
        guard let mutedUntil else { return false }
        if mutedUntil > now { return true }
        self.mutedUntil = AtlasSession.clearExpiredNightlyProposalMute(now: now)
        return false
    }
}

