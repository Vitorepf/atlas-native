import SwiftUI

/// Falha de carregamento Código — canônico (radar + grafo).
/// Retry → AtlasCodeLoadFailure+Retry.swift
/// Icon/copy → AtlasCodeLoadFailure+Icon.swift
struct AtlasCodeLoadFailureEmpty: View {
    let headline: String
    let message: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(spacing: 14) {
            failureIcon
            failureHeadline
            failureMessage
            retryButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(headline). \(message)")
        .accessibilityIdentifier(A11yID.codeLoadFailure)
    }
}
