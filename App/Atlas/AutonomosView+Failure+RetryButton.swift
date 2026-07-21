import SwiftUI

// Retry button — peel de AutonomosView+Failure.

extension AutonomosFleetFailureEmpty {
    var failureRetryButton: some View {
        Button("Tentar de novo", action: onRetry)
            .buttonStyle(AutonomosPrimaryButtonStyle())
            .accessibilityIdentifier(A11yID.autonomosRetry)
            .accessibilityHint("tenta reabrir o catálogo Autônomos")
    }
}
