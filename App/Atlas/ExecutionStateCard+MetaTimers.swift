import SwiftUI
import AtlasCore

// Timer lines — peel de ExecutionStateCard+Meta.
// Frozen → ExecutionStateCard+MetaTimers+Frozen.swift
// Recovering → ExecutionStateCard+MetaTimers+Recovering.swift
// Deadline → ExecutionStateCard+MetaDeadline.swift

extension ExecutionStateCard {
    @ViewBuilder
    var timerMetaLines: some View {
        frozenTimerLine
        recoveringTimerLine
        deadlineMetaLine
    }
}
