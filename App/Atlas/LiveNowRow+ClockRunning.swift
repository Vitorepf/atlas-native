import SwiftUI
import AtlasCore

// Running clock — peel de LiveNowRow+Clock.
// Style → LiveNowRow+ClockStyle.swift

extension LiveNowRow {
    var runningClock: some View {
        TimelineView(.periodic(from: .now, by: reduceMotion ? 60 : 1)) { context in
            clockText(Self.formatClock(
                elapsedMs: session.elapsedActiveMs,
                runningSince: session.runningSince,
                now: context.date,
                paused: false
            ))
        }
    }

    func pausedClock(now: Date) -> some View {
        clockText(Self.formatClock(
            elapsedMs: session.elapsedActiveMs,
            runningSince: nil,
            now: now,
            paused: true
        ))
    }
}
