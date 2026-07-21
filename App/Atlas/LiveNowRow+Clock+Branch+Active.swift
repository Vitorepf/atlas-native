import SwiftUI
import AtlasCore

// Clock active timing — peel de LiveNowRow+Clock+Branch.

extension LiveNowRow {
    @ViewBuilder
    func clockActiveTiming(now: Date) -> some View {
        switch session.timing {
        case .running:
            runningClock
        case .paused:
            pausedClock(now: now)
        default:
            EmptyView()
        }
    }
}
