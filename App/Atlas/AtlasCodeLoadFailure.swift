import SwiftUI

/// Falha de carregamento Código — thin host sobre `AtlasOpsFailureEmpty` (WAVE-008).
struct AtlasCodeLoadFailureEmpty: View {
    let headline: String
    let message: String
    let onRetry: () -> Void

    var body: some View {
        AtlasOpsFailureEmpty(
            mode: .load(headline: headline, message: message),
            layout: .centered,
            symbol: "exclamationmark.triangle",
            topPadding: 0,
            accessibilityIdentifier: A11yID.codeLoadFailure,
            retryAccessibilityIdentifier: A11yID.codeLoadRetry,
            retryHint: "recarrega o grafo ou radar deste repositório",
            spokenOverride: "\(headline). \(message)",
            onRetry: onRetry
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
