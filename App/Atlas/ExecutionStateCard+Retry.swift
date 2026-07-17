import SwiftUI
import AtlasCore

// Retry fallback — peel de ExecutionStateCard+SteerRetry.
// Label → ExecutionStateCard+RetryLabel.swift

extension ExecutionStateCard {
    @ViewBuilder
    var retryFallbackButton: some View {
        if showsRetryFallback, let retryableJobId {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry(retryableJobId)
            } label: {
                retryFallbackLabel
            }
            .buttonStyle(ExecutionStateActionStyle(
                style: .primary,
                reduceMotion: reduceMotion
            ))
            .accessibilityLabel("retomar execução a partir do último checkpoint")
            .accessibilityHint("reenfileira o job que falhou")
        }
    }
}
