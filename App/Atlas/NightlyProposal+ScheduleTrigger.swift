import Foundation
import UserNotifications

/// Nightly trigger math — peel de NightlyProposal+Schedule.

extension NightlyProposalController {
    func nightlyTrigger(dayEnd: DateComponents, now: Date) -> UNNotificationTrigger {
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
}
