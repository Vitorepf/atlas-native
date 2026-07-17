import SwiftUI

/// Falha de carregamento da frota — canônico (substitui VStack inline em AutonomosView).
/// Copy → AutonomosView+FailureCopy.swift
struct AutonomosFleetFailureEmpty: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
            failureCopy
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
