import SwiftUI
import AtlasCore

// Running clock — peel de LiveNowRow+Clock.

extension LiveNowRow {
    var runningClock: some View {
        TimelineView(.periodic(from: .now, by: reduceMotion ? 60 : 1)) { context in
            Text(Self.formatClock(
                elapsedMs: session.elapsedActiveMs,
                runningSince: session.runningSince,
                now: context.date,
                paused: false
            ))
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textSecondary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
        }
    }

    func pausedClock(now: Date) -> some View {
        Text(Self.formatClock(
            elapsedMs: session.elapsedActiveMs,
            runningSince: nil,
            now: now,
            paused: true
        ))
        .font(AtlasFont.serifItalic(13))
        .foregroundStyle(AtlasTheme.textSecondary)
        .monospacedDigit()
        .modifier(NumericTextTransition(enabled: !reduceMotion))
    }
}
