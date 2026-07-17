import SwiftUI
import ActivityKit
import AtlasCore

// Elapsed ms helper — peel de AtlasTurnWidget+TimerText.

extension AtlasTurnWidgetTimer {
    func elapsedMs(now: Date) -> Int {
        Int(max(0, now.timeIntervalSince(startedAt)) * 1000)
    }
}
