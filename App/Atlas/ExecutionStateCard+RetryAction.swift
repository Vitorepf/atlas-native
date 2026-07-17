import SwiftUI
import AtlasCore

// Retry action button — peel de ExecutionStateCard+Retry.

extension ExecutionStateCard {
    @ViewBuilder
    func retryFallbackAction(_ jobId: String) -> some View {
        retryFallbackA11y(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry(jobId)
            } label: {
                retryFallbackLabel
            }
        )
    }
}
