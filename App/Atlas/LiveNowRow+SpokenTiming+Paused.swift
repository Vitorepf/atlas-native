import SwiftUI
import AtlasCore

// Paused spoken — peel de LiveNowRow+SpokenTiming.

extension LiveNowRow {
    func spokenPausedLabel(prefix: String, now: Date) -> String {
        let age = pauseAgeHours(now: now).map { ", há \($0) horas" } ?? ""
        if let clock = spokenClock(now: now) {
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado em \(clock)\(age)"
        }
        return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado, tempo ativo indisponível\(age)"
    }
}
