import SwiftUI
import AtlasCore

/// Relógio ativo RM-safe — peel de LiveSessionWidgetTimer.

extension LiveSessionWidgetTimer {
    @ViewBuilder
    func activeClock(since: Date) -> some View {
        if reduceMotion {
            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                Text(clock(elapsedMs(since: since, now: timeline.date)))
            }
        } else {
            Text(since, style: .timer)
        }
    }
}
