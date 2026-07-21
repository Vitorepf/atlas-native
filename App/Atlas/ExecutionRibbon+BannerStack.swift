import SwiftUI
import AtlasCore

// Reconnect / silence — peel de ExecutionRibbon.
// WAVE-012 dual-surface: while the bubble is live-streaming with reconnect,
// ExecutingStrip owns the primary reconnect face; ribbon stays silent on that
// copy (SilenceWatchdog may still speak as subfase).

extension ExecutionRibbon {
    @ViewBuilder
    var reconnectBannerStack: some View {
        if !(bubble.streaming && bubble.showsReconnectSurface) {
            ReconnectBanner(bubble: bubble, reduceMotion: reduceMotion)
        }
        SilenceWatchdog(bubble: bubble, reduceMotion: reduceMotion)
    }
}
