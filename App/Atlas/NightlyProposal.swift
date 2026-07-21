import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: NightlyProposal + Block + Schedule fused

@MainActor
@Observable
final class NightlyProposalController: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NightlyProposalController()

    let nightlyIdentifier = "atlas.nightly"
    let morningIdentifier = "atlas.morning"
    @ObservationIgnored let center = UNUserNotificationCenter.current()
    @ObservationIgnored var openAutonomos: (() -> Void)?
    @ObservationIgnored var immediateNightlyDateKey: String?

    var pendingProposal: ProposalPayload?
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

    /// Recusas ensinam: 3 seguidas → pausa automática de 7 dias.
    /// WAVE-070: threshold owned by NightlyProposalJudgment.
    static var dismissStreakPauseThreshold: Int {
        NightlyProposalJudgment.dismissStreakPauseThreshold
    }

    func dismissProposal() {
        pendingProposal = nil
        let streak = AtlasSession.recordNightlyProposalDismissal()
        if streak >= Self.dismissStreakPauseThreshold {
            muteProposal(days: 7)
            AtlasSession.setNightlyProposalAutoPaused(true)
        }
    }

    func muteProposal(days: Int, now: Date = .init()) {
        let days = max(1, days)
        let until = AtlasSession.muteNightlyProposal(days: days, now: now)
        mutedUntil = until
        pendingProposal = nil
        AtlasSession.setNightlyProposalAutoPaused(false)
        center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
    }

    func unmuteProposal() {
        AtlasSession.clearNightlyProposalMute()
        AtlasSession.setNightlyProposalAutoPaused(false)
        AtlasSession.resetNightlyProposalStreak()
        mutedUntil = nil
        Task { await scheduleForBackground() }
    }

    func accept(_ proposal: ProposalPayload) async {
        let delayMinutes = Int(Date().timeIntervalSince(proposal.proposedAt) / 60)
        AtlasSession.recordNightlyProposalAccept(delayMinutes: delayMinutes)
        await scheduleMorning(after: proposal)
        pendingProposal = nil
    }

    #if DEBUG
    func installDemoIfRequested(arguments: [String] = ProcessInfo.processInfo.arguments) {
        guard arguments.contains("-atlas.nightly.demo") else { return }
        unmuteProposal()
        pendingProposal = ProposalPayload(workspaces: ["atlas-native"])
    }
    #endif

    func isMuted(now: Date = .init()) -> Bool {
        guard let mutedUntil else { return false }
        if mutedUntil > now { return true }
        self.mutedUntil = AtlasSession.clearExpiredNightlyProposalMute(now: now)
        return false
    }

    func spokenMuteStatus(now: Date = .init()) -> String? {
        // WAVE-070: mute spoken from Judgment.
        NightlyProposalJudgment.spokenMuteStatus(
            isMuted: isMuted(now: now),
            mutedUntil: mutedUntil,
            autoPaused: AtlasSession.nightlyProposalAutoPaused(),
            now: now,
            relativePrazo: { until, relativeTo in
                let formatter = RelativeDateTimeFormatter()
                formatter.locale = Locale(identifier: "pt_BR")
                formatter.unitsStyle = .full
                return formatter.localizedString(for: until, relativeTo: relativeTo)
            }
        )
    }

    /// WAVE-070: exclusive organ face for hosts/pack.
    var proposalFace: NightlyProposalFace {
        NightlyProposalJudgment.face(
            hasPending: pendingProposal != nil,
            isMuted: isProposalMuted,
            autoPaused: AtlasSession.nightlyProposalAutoPaused()
        )
    }

    // MARK: - Payload

    struct ProposalPayload: Identifiable, Equatable {
        let id: String
        let workspaces: [String]
        let proposedAt: Date

        init(workspaces: [String], proposedAt: Date = .init()) {
            self.workspaces = workspaces
            self.proposedAt = proposedAt
            self.id = workspaces.joined(separator: "|") + "-\(Int(proposedAt.timeIntervalSince1970))"
        }

        var workspaceText: String { workspaces.joined(separator: ", ") }

        var prefilledReason: String {
            "missão noturna proposta às \(Self.hourMinute(proposedAt)) — foco: \(workspaceText)"
        }

        private static func hourMinute(_ date: Date) -> String {
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            return String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
        }
    }

    // MARK: - Notification copy

    enum NotificationCopy {
        static let nightlyTitle = "A frota pode trabalhar esta noite"

        static func nightlyBody(workspaces: [String]) -> String {
            "Hoje você mexeu em \(workspaces.joined(separator: ", ")). "
                + "Quer pôr os Autônomos nisso enquanto descansa?"
        }

        static let morningTitle = "Resumo da missão noturna"
        static let morningBody = "Abra Autônomos para ver o que a frota entregou com prova."
    }

    // MARK: - UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let route = userInfo["atlas.route"] as? String
        let workspaces = userInfo["atlas.workspaces"] as? [String]
        await MainActor.run {
            NightlyProposalController.shared.handle(route: route, workspaces: workspaces)
        }
    }

    func handle(route: String?, workspaces: [String]?) {
        guard let route else { return }
        if route == "autonomos-nightly" {
            guard !isMuted() else {
                openAutonomos?()
                return
            }
            guard let workspaces, !workspaces.isEmpty else {
                openAutonomos?()
                return
            }
            pendingProposal = ProposalPayload(workspaces: workspaces)
            openAutonomos?()
        } else if route == "autonomos" {
            openAutonomos?()
        }
    }
}
struct AutonomosNightlyProposalBlock: View {
    let nightly: NightlyProposalController
    let onAccept: (NightlyProposalController.ProposalPayload) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Group { nightlyContent }
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: visibilityToken)
    }

    /// WAVE-070: face drives visibility honesty.
    var proposalFace: NightlyProposalFace { nightly.proposalFace }

    var visibilityToken: String {
        switch proposalFace {
        case .pending:
            return nightly.pendingProposal?.id ?? "pending"
        case .muted, .mutedAuto:
            return "muted"
        case .hidden:
            return "hidden"
        }
    }

    @ViewBuilder
    var nightlyContent: some View {
        if case .pending = proposalFace, let proposal = nightly.pendingProposal {
            NightlyProposalCard(
                proposal: proposal,
                onAccept: { onAccept(proposal) },
                onDismiss: { nightly.dismissProposal() },
                onMute: { nightly.muteProposal(days: $0) }
            )
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
        } else if let spoken = nightly.spokenMuteStatus() {
            Color.clear
                .frame(height: 0)
                .accessibilityLabel(spoken)
                .accessibilityValue(proposalFace.productWord)
                .accessibilityAddTraits(.isStaticText)
        }
    }
}
extension NightlyProposalController {
    // MARK: - Background schedule

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

        center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
        let request = UNNotificationRequest(
            identifier: nightlyIdentifier,
            content: nightlyBackgroundContent(workspaces: summary.workspaces),
            trigger: nightlyTrigger(dayEnd: dayEnd, now: now)
        )
        try? await center.add(request)
    }

    func nightlyBackgroundContent(workspaces: [String]) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = NotificationCopy.nightlyTitle
        content.body = NotificationCopy.nightlyBody(workspaces: workspaces)
        content.sound = .default
        content.userInfo = [
            "atlas.route": "autonomos-nightly",
            "atlas.workspaces": workspaces,
        ]
        return content
    }

    func nightlyTrigger(dayEnd: DateComponents, now: Date) -> UNNotificationTrigger {
        guard var target = Self.date(matching: dayEnd, on: now) else {
            return Self.calendarTrigger(for: now.addingTimeInterval(60))
        }
        target += TimeInterval(AtlasSession.nightlyProposalAdjustmentMinutes() * 60)
        if target <= now {
            let today = Self.dateKey(now)
            if immediateNightlyDateKey != today {
                immediateNightlyDateKey = today
                return Self.calendarTrigger(for: now.addingTimeInterval(60))
            }
            return Self.calendarTrigger(for: Calendar.current.date(byAdding: .day, value: 1, to: target) ?? target)
        }
        return Self.calendarTrigger(for: target)
    }

    func scheduleMorning(after proposal: ProposalPayload) async {
        let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
        guard let dayStart = windows.dayStart,
              let date = nextDayDate(matching: dayStart, after: proposal.proposedAt),
              await canScheduleNotifications() else { return }

        let content = UNMutableNotificationContent()
        content.title = NotificationCopy.morningTitle
        content.body = NotificationCopy.morningBody
        content.sound = .default
        content.userInfo = ["atlas.route": "autonomos"]

        center.removePendingNotificationRequests(withIdentifiers: [morningIdentifier])
        try? await center.add(UNNotificationRequest(
            identifier: morningIdentifier,
            content: content,
            trigger: Self.calendarTrigger(for: date)
        ))
    }

    func canScheduleNotifications() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        switch status {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }

    func nextDayDate(matching components: DateComponents, after date: Date) -> Date? {
        Calendar.current.date(byAdding: .day, value: 1, to: date).flatMap { Self.date(matching: components, on: $0) }
    }

    static func date(matching time: DateComponents, on date: Date) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = time.hour
        components.minute = time.minute
        return Calendar.current.date(from: components)
    }

    static func calendarTrigger(for date: Date) -> UNCalendarNotificationTrigger {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    static func dateKey(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

}
