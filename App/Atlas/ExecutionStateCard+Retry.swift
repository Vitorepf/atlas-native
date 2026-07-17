import SwiftUI
import AtlasCore

// Retry fallback — peel de ExecutionStateCard+SteerRetry.
// Label → ExecutionStateCard+RetryLabel.swift
// A11y → ExecutionStateCard+RetryA11y.swift
// Action → ExecutionStateCard+RetryAction.swift

extension ExecutionStateCard {
    @ViewBuilder
    var retryFallbackButton: some View {
        if showsRetryFallback, let retryableJobId {
            retryFallbackAction(retryableJobId)
        }
    }
}
