import SwiftUI
import AtlasCore

// Retry a11y — peel de ExecutionStateCard+Retry.

extension ExecutionStateCard {
    func retryFallbackA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(ExecutionStateActionStyle(
                style: .primary,
                reduceMotion: reduceMotion
            ))
            .accessibilityIdentifier(A11yID.executionRetry)
            .accessibilityLabel("retomar execução a partir do último checkpoint")
            .accessibilityHint("reenfileira o job que falhou")
    }
}
