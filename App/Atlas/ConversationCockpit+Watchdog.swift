import SwiftUI
import AtlasCore

// Silence watchdog — só com streaming real (WAVE-003 fuse).

struct SilenceWatchdog: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var tickInterval: TimeInterval { reduceMotion ? 30 : 15 }

    var body: some View {
        TimelineView(.periodic(from: .now, by: tickInterval)) { context in
            silenceGate(now: context.date)
        }
    }

    @ViewBuilder
    private func silenceGate(now: Date) -> some View {
        if bubble.streaming,
           let silence = silenceSeconds(now: now),
           silence > 90 {
            Group {
                ExecutionBanner(
                    text: "Sem novos eventos há \(silence)s",
                    icon: "timer",
                    tint: AtlasTheme.domOperacional,
                    reduceMotion: reduceMotion,
                    embedInParent: true
                )
                .modifier(NumericTextTransition(enabled: !reduceMotion))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(SilenceWatchdogA11y.spoken(seconds: silence))
            .accessibilityIdentifier(A11yID.executionSilenceWatchdog)
        }
    }

    private func silenceSeconds(now: Date) -> Int? {
        guard bubble.streaming else { return nil }
        let last = bubble.activities.reversed().compactMap { AtlasTime.date($0.occurredAt) }.first
            ?? bubble.startedAt
        guard let last else { return nil }
        return max(0, Int(now.timeIntervalSince(last)))
    }
}

enum SilenceWatchdogA11y {
    static func spoken(seconds: Int) -> String {
        "execução ao vivo sem novos eventos há \(seconds) segundos"
    }
}
