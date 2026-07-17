import SwiftUI
import AtlasCore

// Spoken awaiting/failed — peel de ExecutionStateCard+AwaitingFailed.
// Summary → ExecutionStateCard+AwaitingFailed+Spoken+Summary.swift

extension ExecutionStateCard {
    var spokenSummary: String { spokenSummaryText }
}
