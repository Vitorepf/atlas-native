import SwiftUI
import AtlasCore

// Spoken label por timing — peel de LiveNowRow+A11y.
// Timing → LiveNowRow+SpokenTiming.swift
// Finished → LiveNowRow+Spoken+Finished.swift

extension LiveNowRow {
    func spokenLabel(hubIndex: Int?, hubCount: Int?, now: Date = .now) -> String {
        let prefix = hubPositionPrefix(index: hubIndex, count: hubCount)
        switch session.timing {
        case .running:
            return spokenRunningLabel(prefix: prefix, now: now)
        case .paused:
            return spokenPausedLabel(prefix: prefix, now: now)
        case .finished:
            return spokenFinishedLabel(prefix: prefix)
        }
    }
}
