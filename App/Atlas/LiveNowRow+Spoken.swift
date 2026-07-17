import SwiftUI
import AtlasCore

// Spoken label por timing — peel de LiveNowRow+A11y.
// Timing → LiveNowRow+SpokenTiming.swift
// Finished → LiveNowRow+Spoken+Finished.swift
// Active → LiveNowRow+Spoken+Active.swift

extension LiveNowRow {
    func spokenLabel(hubIndex: Int?, hubCount: Int?, now: Date = .now) -> String {
        let prefix = hubPositionPrefix(index: hubIndex, count: hubCount)
        return spokenActiveLabel(prefix: prefix, now: now)
            ?? spokenFinishedLabel(prefix: prefix)
    }
}
