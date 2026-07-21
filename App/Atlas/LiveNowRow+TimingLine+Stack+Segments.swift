import SwiftUI
import AtlasCore

// Clock + pause segments — peel de LiveNowRow+TimingLine+Stack.

extension LiveNowRow {
    @ViewBuilder
    func timingLineSegments(now: Date) -> some View {
        timingClockSegment(now: now)
        timingPauseAge(now: now)
    }
}
