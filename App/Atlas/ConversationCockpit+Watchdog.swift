import SwiftUI
import AtlasCore

// Silence watchdog — peel de ConversationCockpit+Agents.

struct SilenceWatchdog: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var body: some View {
        TimelineView(.periodic(from: .now, by: 15)) { context in
            if let silence = silenceSeconds(now: context.date), silence > 90 {
                ExecutionBanner(
                    text: "Sem novos eventos há \(silence)s",
                    icon: "timer",
                    tint: AtlasTheme.domOperacional,
                    reduceMotion: reduceMotion,
                    accessibilityIdentifier: A11yID.executionSilenceWatchdog
                )
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityLabel("sem novos eventos há \(silence) segundos")
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
