import SwiftUI
import AtlasCore

/// Kicker / checkpoint / timer / deadline — peel de ExecutionStateCard (régua ≤100).
// Kicker → ExecutionStateCard+Meta+Kicker.swift
// Timers → ExecutionStateCard+MetaTimers.swift

extension ExecutionStateCard {
    @ViewBuilder var metaLines: some View {
        metaKickerLines
        timerMetaLines
    }
}
