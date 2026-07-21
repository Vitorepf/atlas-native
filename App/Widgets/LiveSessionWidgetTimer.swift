import WidgetKit
import SwiftUI
import AtlasCore

// IDLE-COMPRESS — LiveSession timer host

struct LiveSessionWidgetTimer: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let live: AtlasNativeSnapshot.LiveSession

    var body: some View {
        timerStyle(Group { timerBranchBody })
    }
}

// --- AtlasWidgetAccessories+LiveSession+TimerActive.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+TimerFallback.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+TimerHelpers.swift ---
extension LiveSessionWidgetTimer {
    func elapsedMs(since: Date, now: Date) -> Int {
        Int(max(0, now.timeIntervalSince(since)) * 1000)
    }

    func clock(_ ms: Int?) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms ?? 0)
    }
}

// --- AtlasWidgetAccessories+LiveSession+Titles+Title.swift ---
extension LiveSessionWidgetView {
    func liveSessionTitleLine(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        Text(live.title)
            .font(.system(size: 17, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.ink)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}

// --- AtlasWidgetAccessories+LiveSession+Titles.swift ---
extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionTitles(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTitleLine(live)
        Text(live.phaseTitle)
            .font(.system(size: 14, design: .serif))
            .italic()
            .foregroundStyle(live.timing == .paused ? Ink.gold : Ink.ink2)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}

// --- AtlasWidgetAccessories+LiveSession.swift ---
struct LiveSessionWidgetView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let entry: SnapshotEntry

    var body: some View {
        liveSessionSnapshotGate { snapshot, live, stale in
            liveSessionContent(snapshot: snapshot, live: live, stale: stale)
        }
        .widgetURL(URL(string: "atlas://execution"))
    }
}
