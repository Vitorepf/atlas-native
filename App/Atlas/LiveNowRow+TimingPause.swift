import SwiftUI
import AtlasCore

// Timing pause age — peel de LiveNowRow+TimingLine.

extension LiveNowRow {
    @ViewBuilder
    func timingPauseAge(now: Date) -> some View {
        if session.timing == .paused, let age = pauseAgeHours(now: now) {
            Text("· há \(age)h")
                .font(AtlasFont.serifItalic(12))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}
