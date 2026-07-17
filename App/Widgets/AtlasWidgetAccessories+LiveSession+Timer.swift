import SwiftUI
import AtlasCore

/// Relógio RM-safe do widget Sessão viva — peel de LiveSessionWidgetView.
/// Helpers → AtlasWidgetAccessories+LiveSession+TimerHelpers.swift
/// Fallback → AtlasWidgetAccessories+LiveSession+TimerFallback.swift

struct LiveSessionWidgetTimer: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let live: AtlasNativeSnapshot.LiveSession

    var body: some View {
        Group {
            if live.timing != .paused, let since = live.runningSince.flatMap(AtlasTime.date) {
                activeClock(since: since)
            } else {
                timerFallbackBody
            }
        }
        .font(.system(size: 13, design: .monospaced))
        .foregroundStyle(live.timing == .paused ? Ink.gold : Ink.ink2)
        .accessibilityHidden(true)
    }
}
