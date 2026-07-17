import SwiftUI
import AtlasCore

// Clock spoken — peel de LiveNowRow+A11y.

extension LiveNowRow {
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
