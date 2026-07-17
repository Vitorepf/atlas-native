import SwiftUI
import AtlasCore

// Running spoken — peel de LiveNowRow+SpokenTiming.

extension LiveNowRow {
    func spokenRunningLabel(prefix: String, now: Date) -> String {
        if let clock = spokenClock(now: now) {
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução há \(clock)"
        }
        return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução, tempo ativo indisponível"
    }
}
