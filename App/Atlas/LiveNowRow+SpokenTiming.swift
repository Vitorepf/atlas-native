import SwiftUI
import AtlasCore

// Running/paused spoken — peel de LiveNowRow+Spoken.

extension LiveNowRow {
    func spokenRunningLabel(prefix: String, now: Date) -> String {
        if let clock = spokenClock(now: now) {
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução há \(clock)"
        }
        return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução, tempo ativo indisponível"
    }

    func spokenPausedLabel(prefix: String, now: Date) -> String {
        let age = pauseAgeHours(now: now).map { ", há \($0) horas" } ?? ""
        if let clock = spokenClock(now: now) {
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado em \(clock)\(age)"
        }
        return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado, tempo ativo indisponível\(age)"
    }
}
