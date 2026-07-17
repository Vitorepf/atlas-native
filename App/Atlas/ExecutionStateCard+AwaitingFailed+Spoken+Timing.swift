import SwiftUI
import AtlasCore

// Spoken timing — peel de ExecutionStateCard+AwaitingFailed+Spoken.
// Timer → ExecutionStateCard+AwaitingFailed+Spoken+Timing+Timer.swift
// Deadline → ExecutionStateCard+AwaitingFailed+Spoken+Timing+Deadline.swift

extension ExecutionStateCard {
    func spokenTimingParts(into parts: inout [String]) {
        spokenTimerPart(into: &parts)
        spokenDeadlineParts(into: &parts)
    }
}
