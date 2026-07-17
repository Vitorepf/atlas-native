import SwiftUI
import AtlasCore

// Clock running/paused — peel de LiveNowRow+Clock.
// Active → LiveNowRow+Clock+Branch+Active.swift

extension LiveNowRow {
    @ViewBuilder
    func clockTimingBranch(now: Date) -> some View {
        switch session.timing {
        case .running, .paused:
            clockActiveTiming(now: now)
        case .finished:
            EmptyView()
        }
    }
}
