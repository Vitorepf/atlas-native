import Foundation
import UserNotifications

// Cycle 041 fuse → NightlyProposal+ScheduleCalendar.swift

extension NightlyProposalController {
    func spokenMuteStatus(now: Date = .init()) -> String? {
        guard isMuted(now: now), let until = mutedUntil else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.unitsStyle = .full
        let prazo = formatter.localizedString(for: until, relativeTo: now)
        if AtlasSession.nightlyProposalAutoPaused() {
            return "propostas em pausa — você recusou as últimas \(Self.dismissStreakPauseThreshold); voltam \(prazo)"
        }
        return "propostas noturnas silenciadas até \(prazo)"
    }
}

extension NightlyProposalController {
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
}

extension NightlyProposalController {
    enum NotificationCopy {
        static let nightlyTitle = "A frota pode trabalhar esta noite"

        static func nightlyBody(workspaces: [String]) -> String {
            "Hoje você mexeu em \(workspaces.joined(separator: ", ")). "
                + "Quer pôr os Autônomos nisso enquanto descansa?"
        }

        /// Manhã: convite sem afirmar entrega — fatos só no digest em Autônomos.
        static let morningTitle = "Resumo da missão noturna"
        static let morningBody = "Abra Autônomos para ver o que a frota entregou com prova."
    }
}

extension NightlyProposalController {
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
}

extension NightlyProposalController {
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

extension NightlyProposalController {
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
}

extension NightlyProposalController {
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

extension NightlyProposalController {
    func nightlyTrigger(dayEnd: DateComponents, now: Date) -> UNNotificationTrigger {
        guard var target = Self.date(matching: dayEnd, on: now) else {
            return Self.calendarTrigger(for: now.addingTimeInterval(60))
        }
        // Janela adaptativa: desliza a proposta para o horário em que o
        // operador realmente responde (mediana dos aceites; dita na folha).
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
}
