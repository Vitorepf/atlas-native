import SwiftUI
import AtlasCore

// Silence watchdog — peel de ConversationCockpit+Agents.
// Banner → ConversationCockpit+WatchdogBanner.swift
// Seconds → ConversationCockpit+WatchdogSeconds.swift
// Gate → ConversationCockpit+Watchdog+Gate.swift

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
