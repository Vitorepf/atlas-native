import SwiftUI
import AtlasCore

// Row leading — peel de LiveNowRow+Content+RowStack.
// Trailing → LiveNowRow+Content+RowStack+Trailing.swift

extension LiveNowRow {
    func rowContentLeading(now: Date) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            BreathingDiamond(
                size: 8,
                reduceMotion: reduceMotion || session.timing != .running
            )
            rowTitleStack(now: now)
        }
    }
}
