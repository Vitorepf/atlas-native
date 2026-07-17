import SwiftUI
import AtlasCore

// Reconnect banners — peel de ExecutionRibbon.

extension ExecutionRibbon {
    @ViewBuilder
    var reconnectBannerStack: some View {
        ReconnectBanner(bubble: bubble, reduceMotion: reduceMotion)
        SilenceWatchdog(bubble: bubble, reduceMotion: reduceMotion)
    }
}
