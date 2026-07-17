import SwiftUI
import AtlasCore

// Clock running/paused — peel de LiveNowRow+Clock.

extension LiveNowRow {
    @ViewBuilder
    func clockTimingBranch(now: Date) -> some View {
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
