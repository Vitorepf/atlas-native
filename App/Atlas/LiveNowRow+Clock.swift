import SwiftUI
import AtlasCore

// Clock view — peel de LiveNowRow+Timing.
// A11y → LiveNowRow+ClockA11y.swift
// Running/paused → LiveNowRow+ClockRunning.swift
// Branch → LiveNowRow+Clock+Branch.swift

extension LiveNowRow {
    @ViewBuilder
    func clockView(now: Date) -> some View {
        clockTimingBranch(now: now)
    }
}
