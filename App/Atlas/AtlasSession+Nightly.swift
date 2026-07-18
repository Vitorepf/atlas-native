import Foundation

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
