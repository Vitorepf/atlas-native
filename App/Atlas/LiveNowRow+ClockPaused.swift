import SwiftUI
import AtlasCore

// Paused clock — peel de LiveNowRow+ClockRunning.

extension LiveNowRow {
    func pausedClock(now: Date) -> some View {
        clockText(Self.formatClock(
            elapsedMs: session.elapsedActiveMs,
            runningSince: nil,
            now: now,
            paused: true
        ))
    }
}
