import SwiftUI
import AtlasCore

/// Relógio RM-safe do widget Sessão viva — peel de LiveSessionWidgetView.

struct LiveSessionWidgetTimer: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let live: AtlasNativeSnapshot.LiveSession

    var body: some View {
        Group {
            if live.timing == .paused {
                Text("‖ \(clock(live.elapsedActiveMs))")
            } else if let since = live.runningSince.flatMap(AtlasTime.date) {
                if reduceMotion {
                    TimelineView(.periodic(from: .now, by: 60)) { timeline in
                        Text(clock(elapsedMs(since: since, now: timeline.date)))
                    }
                } else {
                    Text(since, style: .timer)
                }
            } else if let ms = live.elapsedActiveMs {
                Text(clock(ms))
            }
        }
        .font(.system(size: 13, design: .monospaced))
        .foregroundStyle(live.timing == .paused ? Ink.gold : Ink.ink2)
        .accessibilityHidden(true)
    }

    private func elapsedMs(since: Date, now: Date) -> Int {
        Int(max(0, now.timeIntervalSince(since)) * 1000)
    }

    private func clock(_ ms: Int?) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms ?? 0)
    }
}
