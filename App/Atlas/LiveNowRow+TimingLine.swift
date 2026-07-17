import SwiftUI
import AtlasCore

// Timing line — peel de LiveNowRow+Timing.
// Pause → LiveNowRow+TimingPause.swift
// Clock → LiveNowRow+TimingLine+Clock.swift

extension LiveNowRow {
    func timingLine(now: Date) -> some View {
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
