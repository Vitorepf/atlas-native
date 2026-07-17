import SwiftUI
import AtlasCore

// Timing line — peel de LiveNowRow+Timing.
// Pause → LiveNowRow+TimingPause.swift
// Clock → LiveNowRow+TimingLine+Clock.swift
// Stack → LiveNowRow+TimingLine+Stack.swift

extension LiveNowRow {
    func timingLine(now: Date) -> some View {
        timingLineStack(now: now)
    }
}
