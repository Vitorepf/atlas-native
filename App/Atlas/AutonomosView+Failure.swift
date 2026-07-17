import SwiftUI

/// Falha de carregamento da frota — canônico (substitui VStack inline em AutonomosView).
struct AutonomosFleetFailureEmpty: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
            Text("A frota está fora de alcance.")
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(message)
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
            Button("Tentar de novo", action: onRetry)
                .buttonStyle(AutonomosPrimaryButtonStyle())
                .accessibilityIdentifier(A11yID.autonomosRetry)
                .accessibilityHint("reconecta à frota Autônomos")
        }
        .padding(32)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("A frota está fora de alcance. \(message)")
        .accessibilityIdentifier(A11yID.autonomosLoadFailure)
    }
}
