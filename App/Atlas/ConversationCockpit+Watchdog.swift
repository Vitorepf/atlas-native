import AtlasCore
import Foundation
import SwiftUI

// Cycle 024 fuse → ConversationCockpit+Watchdog.swift

/// Só fala quando o stream publica streaming e o contador é real.

enum SilenceWatchdogA11y {
    static func spoken(seconds: Int) -> String {
        "execução ao vivo sem novos eventos há \(seconds) segundos"
    }
}

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

struct SilenceWatchdog: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var tickInterval: TimeInterval { reduceMotion ? 30 : 15 }

    var body: some View {
        TimelineView(.periodic(from: .now, by: tickInterval)) { context in
            silenceGate(now: context.date)
        }
    }
}

extension SilenceWatchdog {
    func silenceBanner(seconds: Int) -> some View {
        Group {
            ExecutionBanner(
                text: "Sem novos eventos há \(seconds)s",
                icon: "timer",
                tint: AtlasTheme.domOperacional,
                reduceMotion: reduceMotion,
                embedInParent: true
            )
            .modifier(NumericTextTransition(enabled: !reduceMotion))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(SilenceWatchdogA11y.spoken(seconds: seconds))
        .accessibilityIdentifier(A11yID.executionSilenceWatchdog)
    }
}

extension SilenceWatchdog {
    func silenceSeconds(now: Date) -> Int? {
        guard bubble.streaming else { return nil }
        let last = bubble.activities.reversed().compactMap { AtlasTime.date($0.occurredAt) }.first
            ?? bubble.startedAt
        guard let last else { return nil }
        return max(0, Int(now.timeIntervalSince(last)))
    }
}
