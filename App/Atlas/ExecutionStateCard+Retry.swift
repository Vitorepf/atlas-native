import SwiftUI
import AtlasCore

// Retry fallback — peel de ExecutionStateCard+SteerRetry.
// Label → ExecutionStateCard+RetryLabel.swift
// A11y → ExecutionStateCard+RetryA11y.swift

extension ExecutionStateCard {
    @ViewBuilder
    var retryFallbackButton: some View {
        if showsRetryFallback, let retryableJobId {
            retryFallbackA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onRetry(retryableJobId)
                } label: {
                    retryFallbackLabel
                }
            )
        }
    }
}
