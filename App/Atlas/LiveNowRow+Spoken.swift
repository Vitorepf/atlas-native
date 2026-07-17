import SwiftUI
import AtlasCore

// Spoken label por timing — peel de LiveNowRow+A11y.

extension LiveNowRow {
    func spokenLabel(hubIndex: Int?, hubCount: Int?, now: Date = .now) -> String {
        let prefix = hubPositionPrefix(index: hubIndex, count: hubCount)
        switch session.timing {
        case .running:
            if let clock = spokenClock(now: now) {
                return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução há \(clock)"
            }
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução, tempo ativo indisponível"
        case .paused:
            let age = pauseAgeHours(now: now).map { ", há \($0) horas" } ?? ""
            if let clock = spokenClock(now: now) {
                return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado em \(clock)\(age)"
            }
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado, tempo ativo indisponível\(age)"
        case .finished:
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), concluído"
        }
    }
}
