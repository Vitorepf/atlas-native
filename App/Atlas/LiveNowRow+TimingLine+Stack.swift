import SwiftUI
import AtlasCore

// Timing HStack — peel de LiveNowRow+TimingLine.

extension LiveNowRow {
    func timingLineStack(now: Date) -> some View {
        HStack(spacing: 6) {
            Text(timingWord)
                .font(AtlasFont.mono(10))
                .tracking(0.3)
                .foregroundStyle(timingColor)
            timingClockSegment(now: now)
            timingPauseAge(now: now)
        }
    }
}
