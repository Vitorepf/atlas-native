import SwiftUI
import AtlasCore

// Watchdog gate — peel de ConversationCockpit+Watchdog.

extension SilenceWatchdog {
    @ViewBuilder
    func silenceGate(now: Date) -> some View {
        if bubble.streaming,
           let silence = silenceSeconds(now: now),
           silence > 90 {
            silenceBanner(seconds: silence)
        }
    }
}
