import SwiftUI
import AtlasCore

// Estados vazios do WorkspaceView (offline) — voz partilhada via AtlasFailureCopy.
// Editorial → WorkspaceEmptyStates+Editorial.swift · Loading → +Loading.
// Ops failure canon → AtlasOpsFailureEmpty (WAVE-008).

/// Falha de rede compartilhada — home, workspace e conversa.
/// Thin host sobre `AtlasOpsFailureEmpty` (mesma máquina que Code/Arena/Autônomos).
struct AtlasNetworkFailureEmpty: View {
    let kind: AtlasNetworkFailureKind?
    let hasToken: Bool
    let host: String
    var topPadding: CGFloat = 56
    var retryHint: String = "reconecta ao servidor Atlas"
    var retryAccessibilityIdentifier: String?
    let accessibilityIdentifier: String
    let onRetry: () -> Void

    var body: some View {
        AtlasOpsFailureEmpty(
            mode: .network(kind: kind, hasToken: hasToken, host: host),
            layout: .centered,
            topPadding: topPadding,
            accessibilityIdentifier: accessibilityIdentifier,
            retryAccessibilityIdentifier: retryAccessibilityIdentifier,
            retryHint: retryHint,
            onRetry: onRetry
        )
    }
}
