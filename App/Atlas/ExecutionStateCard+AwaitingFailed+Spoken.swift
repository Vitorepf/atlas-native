import SwiftUI
import AtlasCore

// Spoken awaiting/failed — peel de ExecutionStateCard+AwaitingFailed.
// Actions → ExecutionStateCard+AwaitingFailed+SpokenActions.swift
// Failure → ExecutionStateCard+AwaitingFailed+Failure.swift
// Detail → ExecutionStateCard+AwaitingFailed+Spoken+Detail.swift
// Timing → ExecutionStateCard+AwaitingFailed+Spoken+Timing.swift

extension ExecutionStateCard {
    var spokenSummary: String {
        var parts: [String] = []
        if let kind = spokenKind { parts.append(kind) }
        parts.append(state.title)
        spokenDetailParts(into: &parts)
        spokenTimingParts(into: &parts)
        return parts.joined(separator: ". ")
    }
}
