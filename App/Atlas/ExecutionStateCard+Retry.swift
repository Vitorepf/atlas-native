import SwiftUI
import AtlasCore

// Retry fallback — peel de ExecutionStateCard+SteerRetry.

extension ExecutionStateCard {
    @ViewBuilder
    var retryFallbackButton: some View {
        if showsRetryFallback, let retryableJobId {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry(retryableJobId)
            } label: {
                Text("Retomar")
                    .font(.system(.caption, weight: .semibold))
                    .padding(.horizontal, 11).padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
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
