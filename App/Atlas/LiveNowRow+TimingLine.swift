import SwiftUI
import AtlasCore

// Timing line — peel de LiveNowRow+Timing.
// Pause → LiveNowRow+TimingPause.swift

extension LiveNowRow {
    func timingLine(now: Date) -> some View {
        HStack(spacing: 6) {
            Text(timingWord)
                .font(AtlasFont.mono(10))
                .tracking(0.3)
                .foregroundStyle(timingColor)
            if session.timing != .finished {
                Text("·")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                clockView(now: now)
                    .accessibilityLabel(clockAccessibilityLabel(now: now))
            }
            timingPauseAge(now: now)
        }
    }
}
