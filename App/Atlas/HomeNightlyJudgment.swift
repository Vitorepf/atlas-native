import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: density split — nightly

// MARK: - NightlyProposal

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
        static let productNightlyTitle = "A frota pode trabalhar esta noite"

        static func nightlyBody(workspaces: [String]) -> String {
            "Hoje você mexeu em \(workspaces.joined(separator: ", ")). "
                + "Quer pôr os Autônomos nisso enquanto descansa?"
        }

        static let productMorningTitle = "Resumo da missão noturna"
        static let productMorningBody = "Abra Autônomos para ver o que a frota entregou com prova."
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
        content.title = NotificationCopy.productNightlyTitle
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
        content.title = NotificationCopy.productMorningTitle
        content.body = NotificationCopy.productMorningBody
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

// MARK: - Judgment

// MARK: - Types

/// Exclusive nightly proposal organ face (WAVE-070).
enum NightlyProposalFace: Equatable {
    case pending
    case muted
    case mutedAuto
    case hidden

    var productWord: String {
        switch self {
        case .pending: return "pending"
        case .muted: return "muted"
        case .mutedAuto: return "muted_auto"
        case .hidden: return "hidden"
        }
    }

    var spokenFace: String {
        switch self {
        case .pending:
            return "missão noturna proposta"
        case .muted:
            return "propostas noturnas em pausa"
        case .mutedAuto:
            return "propostas em pausa após recusas"
        case .hidden:
            return "sem proposta noturna"
        }
    }
}

// MARK: - Judgment

/// Pure nightly-proposal grammar — face · spoken · pack.
enum NightlyProposalJudgment {

    static let dismissStreakPauseThreshold = 3
    static let muteDays: [Int] = [1, 3, 7]

    static func face(
        hasPending: Bool,
        isMuted: Bool,
        autoPaused: Bool
    ) -> NightlyProposalFace {
        if isMuted {
            return autoPaused ? .mutedAuto : .muted
        }
        if hasPending { return .pending }
        return .hidden
    }

    static let spokenAcceptLabel = "preparar missão noturna"
    static let spokenRhythmLineHint = "mostra o que o Atlas aprendeu do seu dia"
    static let spokenAcceptHint = "abre o ensaio governado da missão noturna"
    static let spokenDismissLabel = "hoje não"
    static let productUnmute = "Reativar propostas noturnas"
    static let productFleetWhileRest = "A frota pode continuar enquanto você descansa."
    static func productWorkedToday(workspaceText: String) -> String { "Hoje você trabalhou em \(workspaceText)." }
    static let spokenDismissHint = "descarta a proposta em silêncio, sem confirmação"
    static let spokenMuteMenuLabel = "pausar propostas noturnas"
    static let spokenMuteMenuHint =
        "oculta card e notificações por 1, 3 ou 7 dias; propostas ficam em pausa"

    static func spokenMuteOption(days: Int) -> String {
        "pausar por \(days) \(days == 1 ? "dia" : "dias")"
    }

    static let spokenMuteOptionHint =
        "remove a proposta e pausa notificações, sem toast"

    /// Relative mute status for a11y when muted (nil when not muted).
    static func spokenMuteStatus(
        isMuted: Bool,
        mutedUntil: Date?,
        autoPaused: Bool,
        now: Date = .init(),
        relativePrazo: (Date, Date) -> String
    ) -> String? {
        guard isMuted, let until = mutedUntil else { return nil }
        let prazo = relativePrazo(until, now)
        if autoPaused {
            return "propostas em pausa — você recusou as últimas \(dismissStreakPauseThreshold); voltam \(prazo)"
        }
        return "propostas noturnas em pausa até \(prazo)"
    }

    static func packFacts(
        hasPending: Bool,
        isMuted: Bool,
        autoPaused: Bool,
        workspaceText: String?,
        mutedUntil: Date?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(hasPending: hasPending, isMuted: isMuted, autoPaused: autoPaused)
        facts.append("nightly_face: \(face.productWord)")
        switch face {
        case .pending:
            if let workspaceText, !workspaceText.isEmpty {
                facts.append("nightly_workspaces: \(workspaceText)")
            } else {
                absences.append("proposta sem workspaces publicados")
            }
        case .muted, .mutedAuto:
            absences.append("propostas noturnas mutadas")
            if let mutedUntil {
                facts.append("nightly_muted_until_s: \(Int(mutedUntil.timeIntervalSince1970))")
            }
            if autoPaused {
                facts.append("nightly_auto_paused: true")
            }
        case .hidden:
            absences.append("sem proposta noturna neste recorte")
        }
        return (facts, absences)
    }
}

// MARK: - NightlyProposalCard

// MARK: - Host

struct NightlyProposalCard: View {
    let proposal: NightlyProposalController.ProposalPayload
    let onAccept: () -> Void
    /// Silêncio: some o card sem toast, sem confirmação, sem fila.
    let onDismiss: () -> Void
    let onMute: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    /// Hora aprendida do fim do dia — o masthead diz o ritmo real, não "21h" fixo.
    @State var learnedDayEnd: String?

    var body: some View {
        cardA11y
            .task {
                let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
                learnedDayEnd = AutonomosRhythmCopy.hour(windows.dayEnd)
            }
    }
}

// MARK: - Body

extension NightlyProposalCard {
    var cardA11y: some View {
        cardChrome
            // .contain preserva botões Preparar/hoje não; o id do card fica
            // no contentor sem engolir os CTAs (XCUITest + VoiceOver).
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.nightlyProposalCard)
            // WAVE-070: exclusive face when card is visible = pending.
            .accessibilityValue(NightlyProposalFace.pending.productWord)
    }
}

extension NightlyProposalCard {
    var actionRow: some View {
        HStack(spacing: 10) {
            Button(NightlyProposalJudgment.spokenAcceptLabel) {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onAccept()
            }
            .buttonStyle(AutonomosPrimaryButtonStyle())
            .accessibilityIdentifier(A11yID.nightlyProposalAccept)
            .accessibilityLabel(Self.spokenAcceptLabel())
            .accessibilityHint(Self.spokenAcceptHint())
            dismissButton
            muteMenu
        }
    }
}

extension NightlyProposalCard {
    var cardChrome: some View {
        VStack(alignment: .leading, spacing: 12) {
            masthead
            copyBlock
            actionRow
        }
        .padding(14)
        .atlasCard(cornerRadius: AtlasTheme.Radius.card)
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(AtlasTheme.goldBorder, lineWidth: 1))
    }
}

extension NightlyProposalCard {
    var masthead: some View {
        HStack(spacing: 8) {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Text(learnedDayEnd.map { "MISSÃO NOTURNA · NO SEU RITMO (~\($0))" }
                ?? "MISSÃO NOTURNA · NO SEU RITMO")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension NightlyProposalCard {
    var copyBlock: some View {
        Group {
            Text(NightlyProposalJudgment.productWorkedToday(workspaceText: proposal.workspaceText))
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            Text(NightlyProposalJudgment.productFleetWhileRest)
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}

extension NightlyProposalCard {
    var dismissButton: some View {
        Button(NightlyProposalJudgment.spokenDismissLabel) {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onDismiss()
        }
        .font(AtlasFont.mono(11, .semibold))
        .foregroundStyle(AtlasTheme.textTertiary)
        .buttonStyle(PressableScale())
        .accessibilityIdentifier(A11yID.nightlyProposalDismiss)
        .accessibilityLabel(Self.spokenDismissLabel())
        .accessibilityHint(Self.spokenDismissHint())
    }
}

extension NightlyProposalCard {
    var muteMenu: some View {
        Menu("pausar") {
            ForEach(NightlyProposalJudgment.muteDays, id: \.self) { days in
                Button("\(days) dia\(days == 1 ? "" : "s")") {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onMute(days)
                }
                .accessibilityLabel(Self.spokenMuteOption(days: days))
                .accessibilityHint(Self.spokenMuteOptionHint())
            }
        }
        .font(AtlasFont.mono(11, .semibold))
        .foregroundStyle(AtlasTheme.textTertiary)
        .accessibilityIdentifier(A11yID.nightlyProposalMute)
        .accessibilityLabel(Self.spokenMuteMenuLabel())
        .accessibilityHint(Self.spokenMuteMenuHint())
    }
}

extension NightlyProposalCard {
    /// WAVE-070: spoken actions from NightlyProposalJudgment.

    static func spokenAcceptLabel() -> String {
        NightlyProposalJudgment.spokenAcceptLabel
    }

    static func spokenAcceptHint() -> String {
        NightlyProposalJudgment.spokenAcceptHint
    }

    static func spokenDismissLabel() -> String {
        NightlyProposalJudgment.spokenDismissLabel
    }

    static func spokenDismissHint() -> String {
        NightlyProposalJudgment.spokenDismissHint
    }

    static func spokenMuteMenuLabel() -> String {
        NightlyProposalJudgment.spokenMuteMenuLabel
    }

    static func spokenMuteMenuHint() -> String {
        NightlyProposalJudgment.spokenMuteMenuHint
    }

    static func spokenMuteOption(days: Int) -> String {
        NightlyProposalJudgment.spokenMuteOption(days: days)
    }

    static func spokenMuteOptionHint() -> String {
        NightlyProposalJudgment.spokenMuteOptionHint
    }
}

