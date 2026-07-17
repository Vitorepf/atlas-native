import SwiftUI
import AtlasCore

// Silence watchdog — peel de ConversationCockpit+Agents.

struct SilenceWatchdog: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    private var tickInterval: TimeInterval { reduceMotion ? 30 : 15 }

    var body: some View {
        TimelineView(.periodic(from: .now, by: tickInterval)) { context in
            if bubble.streaming,
               let silence = silenceSeconds(now: context.date),
               silence > 90 {
                Group {
                    ExecutionBanner(
                        text: "Sem novos eventos há \(silence)s",
                        icon: "timer",
                        tint: AtlasTheme.domOperacional,
                        reduceMotion: reduceMotion
                    )
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(SilenceWatchdogA11y.spoken(seconds: silence))
                .accessibilityIdentifier(A11yID.executionSilenceWatchdog)
            }
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
