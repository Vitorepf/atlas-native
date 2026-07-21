import SwiftUI

// Cycle 040 fuse → AtlasCodeLoadFailure+Retry.swift

extension AtlasCodeLoadFailureEmpty {
    var retryButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRetry()
        } label: {
            Text("Tentar de novo")
        }
        .buttonStyle(.borderedProminent)
        .tint(AtlasTheme.accent)
        .accessibilityLabel("tentar de novo")
        .accessibilityHint("recarrega o grafo ou radar deste repositório")
        .accessibilityIdentifier(A11yID.codeLoadRetry)
    }
}
