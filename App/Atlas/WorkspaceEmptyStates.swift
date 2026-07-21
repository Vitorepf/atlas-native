import AtlasCore
import SwiftUI

// Cycle 041 fuse → WorkspaceEmptyStates.swift

// Estados vazios do WorkspaceView (offline) —

/// Falha de rede compartilhada — home, workspace e conversa (voz via `AtlasFailureCopy`).
struct AtlasNetworkFailureEmpty: View {
    let kind: AtlasNetworkFailureKind?
    let hasToken: Bool
    let host: String
    var topPadding: CGFloat = 56
    var retryHint: String = "reconecta ao servidor Atlas"
    var retryAccessibilityIdentifier: String?
    let accessibilityIdentifier: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        failureChrome(failureCopyBlock)
    }
}
