import SwiftUI
import AtlasCore

/// Relógio paused/fallback — peel de LiveSessionWidgetTimer.

extension LiveSessionWidgetTimer {
    @ViewBuilder
    var timerFallbackBody: some View {
        if live.timing == .paused {
            Text("‖ \(clock(live.elapsedActiveMs))")
        } else if let ms = live.elapsedActiveMs {
            Text(clock(ms))
        }
    }
}
