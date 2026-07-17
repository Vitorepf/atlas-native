import SwiftUI

/// Falha de carregamento Código — canônico (radar + grafo).
/// Retry → AtlasCodeLoadFailure+Retry.swift
/// Icon/copy → AtlasCodeLoadFailure+Icon.swift
/// Stack → AtlasCodeLoadFailure+Stack.swift
struct AtlasCodeLoadFailureEmpty: View {
    let headline: String
    let message: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        failureStack
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(headline). \(message)")
            .accessibilityIdentifier(A11yID.codeLoadFailure)
    }
}
