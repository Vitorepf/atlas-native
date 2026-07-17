import SwiftUI
import AtlasCore

// Clock view — peel de LiveNowRow+Timing.
// A11y → LiveNowRow+ClockA11y.swift
// Running/paused → LiveNowRow+ClockRunning.swift

extension LiveNowRow {
    @ViewBuilder
    func clockView(now: Date) -> some View {
        switch session.timing {
        case .running:
            runningClock
        case .paused:
            pausedClock(now: now)
        case .finished:
            EmptyView()
        }
    }
}
