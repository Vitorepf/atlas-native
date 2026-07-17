import SwiftUI

/// Falha de carregamento Código — canônico (radar + grafo).
/// Retry → AtlasCodeLoadFailure+Retry.swift
/// Icon/copy → AtlasCodeLoadFailure+Icon.swift
/// Stack → AtlasCodeLoadFailure+Stack.swift
/// A11y → AtlasCodeLoadFailure+A11y.swift
struct AtlasCodeLoadFailureEmpty: View {
    let headline: String
    let message: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        failureA11y
    }
}
