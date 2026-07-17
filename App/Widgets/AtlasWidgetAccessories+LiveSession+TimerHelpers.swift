import SwiftUI
import AtlasCore

/// Timer helpers — peel de LiveSessionWidgetTimer.

extension LiveSessionWidgetTimer {
    func elapsedMs(since: Date, now: Date) -> Int {
        Int(max(0, now.timeIntervalSince(since)) * 1000)
    }

    func clock(_ ms: Int?) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms ?? 0)
    }
}
