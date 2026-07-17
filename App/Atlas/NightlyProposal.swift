import SwiftUI
import UserNotifications

@MainActor
@Observable
final class NightlyProposalController: NSObject, UNUserNotificationCenterDelegate {
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

    static let shared = NightlyProposalController()

    private let nightlyIdentifier = "atlas.nightly"
    private let morningIdentifier = "atlas.morning"
    @ObservationIgnored private let center = UNUserNotificationCenter.current()
    @ObservationIgnored private var openAutonomos: (() -> Void)?
    @ObservationIgnored private var immediateNightlyDateKey: String?

    private(set) var pendingProposal: ProposalPayload?
    private(set) var mutedUntil: Date?

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

    private func handle(route: String?, workspaces: [String]?) {
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

    private func scheduleMorning(after proposal: ProposalPayload) async {
        let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
        guard let dayStart = windows.dayStart,
              let date = nextDayDate(matching: dayStart, after: proposal.proposedAt),
              await canScheduleNotifications() else { return }

        let content = UNMutableNotificationContent()
        content.title = "A frota trabalhou esta noite"
        content.body = "Veja as entregas comprovadas."
        content.sound = .default
        content.userInfo = ["atlas.route": "autonomos"]

        center.removePendingNotificationRequests(withIdentifiers: [morningIdentifier])
        try? await center.add(UNNotificationRequest(
            identifier: morningIdentifier,
            content: content,
            trigger: Self.calendarTrigger(for: date)
        ))
    }

    private func canScheduleNotifications() async -> Bool {
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

    private func nightlyTrigger(dayEnd: DateComponents, now: Date) -> UNNotificationTrigger {
        guard let target = Self.date(matching: dayEnd, on: now) else {
            return Self.calendarTrigger(for: now.addingTimeInterval(60))
        }
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

    private func nextDayDate(matching components: DateComponents, after date: Date) -> Date? {
        Calendar.current.date(byAdding: .day, value: 1, to: date).flatMap { Self.date(matching: components, on: $0) }
    }

    private static func date(matching time: DateComponents, on date: Date) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = time.hour
        components.minute = time.minute
        return Calendar.current.date(from: components)
    }

    private static func calendarTrigger(for date: Date) -> UNCalendarNotificationTrigger {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    private static func dateKey(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    private func isMuted(now: Date = .init()) -> Bool {
        guard let mutedUntil else { return false }
        if mutedUntil > now { return true }
        self.mutedUntil = AtlasSession.clearExpiredNightlyProposalMute(now: now)
        return false
    }
}

struct NightlyProposalCard: View {
    let proposal: NightlyProposalController.ProposalPayload
    let onAccept: () -> Void
    let onDismiss: () -> Void
    let onMute: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                    .accessibilityHidden(true)
                Text("MISSÃO NOTURNA · PROPOSTA DAS 21H")
                    .font(AtlasFont.mono(10))
                    .tracking(1.1)
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            Text("Hoje você trabalhou em \(proposal.workspaceText).")
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("A frota pode continuar enquanto você descansa.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                Button("Preparar missão noturna", action: onAccept)
                    .buttonStyle(NightlyPrimaryButtonStyle())
                    .accessibilityIdentifier(A11yID.nightlyProposalAccept)
                Button("hoje não", action: onDismiss)
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .buttonStyle(PressableScale())
                    .accessibilityIdentifier(A11yID.nightlyProposalDismiss)
                Menu("silenciar") {
                    Button("1 dia") { onMute(1) }
                    Button("3 dias") { onMute(3) }
                    Button("7 dias") { onMute(7) }
                }
                .font(.system(.footnote, weight: .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .padding(14)
        .atlasCard(cornerRadius: 14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.nightlyProposalCard)
        .animation(reduceMotion ? nil : AtlasMotion.arrival, value: proposal.id)
    }
}

private struct NightlyPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.footnote, weight: .semibold))
            .foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 13)
            .padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.accent.opacity(configuration.isPressed ? 0.72 : 1)))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
