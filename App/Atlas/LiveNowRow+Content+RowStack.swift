import SwiftUI
import AtlasCore

// Row HStack — peel de LiveNowRow+Content.

extension LiveNowRow {
    func rowContentStack(now: Date) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            BreathingDiamond(
                size: 8,
                reduceMotion: reduceMotion || session.timing != .running
            )
            rowTitleStack(now: now)
            Spacer(minLength: 0)
            rowChevron
        }
        .opacity(isLongPaused(now: now) ? 0.58 : 1)
    }
}
