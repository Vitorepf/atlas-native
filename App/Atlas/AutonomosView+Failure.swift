import SwiftUI

/// Falha de carregamento do catálogo Autônomos.
struct AutonomosFleetFailureEmpty: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
            Text("Catálogo fora de alcance.")
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(message)
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
            Button("Tentar de novo", action: onRetry)
                .buttonStyle(AutonomosPrimaryButtonStyle())
                .accessibilityIdentifier(A11yID.autonomosRetry)
                .accessibilityHint("tenta reabrir o catálogo Autônomos")
        }
        .padding(32)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Catálogo Autônomos fora de alcance. \(message)")
        .accessibilityIdentifier(A11yID.autonomosLoadFailure)
    }
}
