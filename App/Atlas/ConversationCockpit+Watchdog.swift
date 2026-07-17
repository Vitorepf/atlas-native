import SwiftUI
import AtlasCore

// Silence watchdog — peel de ConversationCockpit+Agents.
// Banner → ConversationCockpit+WatchdogBanner.swift

struct SilenceWatchdog: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var tickInterval: TimeInterval { reduceMotion ? 30 : 15 }

    var body: some View {
        TimelineView(.periodic(from: .now, by: tickInterval)) { context in
            if bubble.streaming,
               let silence = silenceSeconds(now: context.date),
               silence > 90 {
                silenceBanner(seconds: silence)
            }
        }
    }

    func silenceSeconds(now: Date) -> Int? {
        guard bubble.streaming else { return nil }
        let last = bubble.activities.reversed().compactMap { AtlasTime.date($0.occurredAt) }.first
            ?? bubble.startedAt
        guard let last else { return nil }
        return max(0, Int(now.timeIntervalSince(last)))
    }
}
