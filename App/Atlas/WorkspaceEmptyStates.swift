import SwiftUI
import AtlasCore

// Estados vazios do WorkspaceView (offline) —
// peel anti-inchaço; voz partilhada com a home via AtlasFailureCopy.
// Loading → +Loading · Editorial → +Editorial · Retry → +Retry · Copy → +FailureCopy.

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
        failureCopyBlock
        .padding(.horizontal, 44).padding(.top, topPadding)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityLabel("\(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)). \(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))")
    }
}
