import SwiftUI

/// Falha de carregamento Autônomos — thin host sobre `AtlasOpsFailureEmpty` (WAVE-008).
struct AutonomosFleetFailureEmpty: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        AtlasOpsFailureEmpty(
            mode: .load(headline: "Catálogo fora de alcance.", message: message),
            layout: .centered,
            symbol: "exclamationmark.triangle",
            topPadding: 0,
            accessibilityIdentifier: A11yID.autonomosLoadFailure,
            retryAccessibilityIdentifier: A11yID.autonomosRetry,
            retryHint: "tenta reabrir o catálogo Autônomos",
            spokenOverride: "Catálogo Autônomos fora de alcance. \(message)",
            onRetry: onRetry
        )
        .padding(32)
    }
}
