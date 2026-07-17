import SwiftUI
import AtlasCore

// Title / phase stack — peel de LiveNowRow+Content.

extension LiveNowRow {
    func rowTitleStack(now: Date) -> some View {
        VStack(alignment: .leading, spacing: hubMode ? 4 : 3) {
            Text(session.title)
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .layoutPriority(1)
            HStack(spacing: 6) {
                Text(session.phaseTitle)
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                if session.isRemote {
                    remoteBadge
                }
            }
            // Timing explícito (running/paused) + elapsed.
            timingLine(now: now)
        }
    }
}
