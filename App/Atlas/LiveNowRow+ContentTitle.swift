import SwiftUI
import AtlasCore

// Title / phase stack — peel de LiveNowRow+Content.
// Phase → LiveNowRow+ContentPhase.swift

extension LiveNowRow {
    func rowTitleStack(now: Date) -> some View {
        VStack(alignment: .leading, spacing: hubMode ? 4 : 3) {
            Text(session.title)
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .layoutPriority(1)
            rowPhaseLine
            // Timing explícito (running/paused) + elapsed.
            timingLine(now: now)
        }
    }
}
