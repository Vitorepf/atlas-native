import SwiftUI

/// Falha de carregamento da frota — canônico (substitui VStack inline em AutonomosView).
/// Copy → AutonomosView+FailureCopy.swift
/// Icon → AutonomosView+Failure+Icon.swift
/// Retry → AutonomosView+Failure+RetryButton.swift
struct AutonomosFleetFailureEmpty: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            failureIcon
            failureCopy
            failureRetryButton
        }
        .padding(32)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("A frota está fora de alcance. \(message)")
        .accessibilityIdentifier(A11yID.autonomosLoadFailure)
    }
}
