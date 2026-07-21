import SwiftUI
import AtlasCore

// Spoken detail — peel de ExecutionStateCard+AwaitingFailed+Spoken.
// Reason → ExecutionStateCard+AwaitingFailed+Spoken+Detail+Reason.swift
// Meta → ExecutionStateCard+AwaitingFailed+Spoken+Detail+Meta.swift

extension ExecutionStateCard {
    func spokenDetailParts(into parts: inout [String]) {
        spokenReasonParts(into: &parts)
        spokenMetaParts(into: &parts)
    }
}
