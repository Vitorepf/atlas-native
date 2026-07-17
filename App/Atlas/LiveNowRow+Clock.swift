import SwiftUI
import AtlasCore

// Clock view — peel de LiveNowRow+Timing.

extension LiveNowRow {
    @ViewBuilder
    func clockView(now: Date) -> some View {
        switch session.timing {
        case .running:
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
        case .paused:
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
        case .finished:
            EmptyView()
        }
    }

    func clockAccessibilityLabel(now: Date) -> String {
        guard let clock = spokenClock(now: now) else {
            return "tempo ativo indisponível"
        }
        return session.timing == .paused
            ? "tempo ativo congelado em \(clock)"
            : "tempo ativo \(clock)"
    }
}
