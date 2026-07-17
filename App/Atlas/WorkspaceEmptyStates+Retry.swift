import SwiftUI
import AtlasCore

// Retry CTA — peel de WorkspaceEmptyStates / AtlasNetworkFailureEmpty.
// Identifier → WorkspaceEmptyStates+Retry+Identifier.swift

extension AtlasNetworkFailureEmpty {
    @ViewBuilder
    var retryButton: some View {
        retryButtonWithIdentifier(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry()
            } label: {
                retryLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("tentar de novo")
            .accessibilityHint(retryHint)
        )
    }
}
