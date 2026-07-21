import SwiftUI
import AtlasCore

// Clock segment — peel de LiveNowRow+TimingLine.

extension LiveNowRow {
    @ViewBuilder
    func timingClockSegment(now: Date) -> some View {
        if session.timing != .finished {
            Text("·")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            clockView(now: now)
                .accessibilityLabel(clockAccessibilityLabel(now: now))
        }
    }
}
