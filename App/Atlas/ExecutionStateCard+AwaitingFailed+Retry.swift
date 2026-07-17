import SwiftUI
import AtlasCore

// Retry fallback predicate — peel de ExecutionStateCard+AwaitingFailed+Leave.
// CopyLeave → ExecutionStateCard+AwaitingFailed+CopyLeave.swift

extension ExecutionStateCard {
    var showsRetryFallback: Bool {
        state.kind == .failed
            && state.actions.isEmpty
            && retryableJobId != nil
    }
}
