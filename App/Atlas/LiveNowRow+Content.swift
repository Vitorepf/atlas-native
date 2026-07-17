import SwiftUI
import AtlasCore

// Conteúdo da linha — peel de LiveNowRow.
// Remote badge → LiveNowRow+RemoteBadge.swift
// Chevron → LiveNowRow+Chevron.swift

extension LiveNowRow {
    var rowContent: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                BreathingDiamond(
                    size: 8,
                    reduceMotion: reduceMotion || session.timing != .running
                )
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
                    timingLine(now: context.date)
                }
                Spacer(minLength: 0)
                rowChevron
            }
            .opacity(isLongPaused(now: context.date) ? 0.58 : 1)
        }
    }
}
