import SwiftUI
import AtlasCore

// Spoken lead — peel de ExecutionStateCard+AwaitingFailed+Spoken+Summary.
// Tail → ExecutionStateCard+AwaitingFailed+Spoken+Summary+Tail.swift

extension ExecutionStateCard {
    func spokenSummaryLead(into parts: inout [String]) {
        if let kind = spokenKind { parts.append(kind) }
        parts.append(state.title)
    }
}
