import SwiftUI
import AtlasCore

// Spoken labels do LiveNow row — fusão idle dos peels LiveNowRow+A11y* / Spoken*.

extension LiveNowRow {
    var remoteSuffix: String {
        session.isRemote ? ", remota em outra superfície" : ""
    }

    func hubPositionPrefix(index: Int?, count: Int?) -> String {
        guard let index, let count, count >= 2 else { return "" }
        return "sessão \(index + 1) de \(count), "
    }

    func hasMeasurableClock(now: Date) -> Bool {
        session.elapsedActiveMs != nil
    }

    func spokenClock(now: Date) -> String? {
        guard hasMeasurableClock(now: now) else { return nil }
        return Self.formatClock(
            elapsedMs: session.elapsedActiveMs,
            runningSince: session.runningSince,
            now: now,
            paused: session.timing == .paused
        )
    }

    func spokenLabel(hubIndex: Int?, hubCount: Int?, now: Date = .now) -> String {
        let prefix = hubPositionPrefix(index: hubIndex, count: hubCount)
        return spokenActiveLabel(prefix: prefix, now: now)
            ?? spokenFinishedLabel(prefix: prefix)
    }

    func spokenActiveLabel(prefix: String, now: Date) -> String? {
        switch session.timing {
        case .running:
            return spokenRunningLabel(prefix: prefix, now: now)
        case .paused:
            return spokenPausedLabel(prefix: prefix, now: now)
        default:
            return nil
        }
    }

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

    func spokenFinishedLabel(prefix: String) -> String {
        "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), concluído"
    }
}
