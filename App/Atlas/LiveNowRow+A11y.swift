import SwiftUI
import AtlasCore

/// Spoken helpers — peel de LiveNowRow (CICLO C residual honesty).
/// Spoken label → LiveNowRow+Spoken.swift

extension LiveNowRow {
    var remoteSuffix: String {
        session.isRemote ? ", sessão remota em outra superfície" : ""
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
}
