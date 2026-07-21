import SwiftUI
import AtlasCore

// Spoken summary assembly — peel de ExecutionStateCard+AwaitingFailed+Spoken.
// Lead → ExecutionStateCard+AwaitingFailed+Spoken+Summary+Lead.swift
// Tail → ExecutionStateCard+AwaitingFailed+Spoken+Summary+Tail.swift

extension ExecutionStateCard {
    var spokenSummaryText: String {
        var parts: [String] = []
        spokenSummaryLead(into: &parts)
        spokenSummaryTail(into: &parts)
        return parts.joined(separator: ". ")
    }
}
