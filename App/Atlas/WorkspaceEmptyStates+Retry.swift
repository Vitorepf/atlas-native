import SwiftUI
import AtlasCore

// Retry CTA — peel de WorkspaceEmptyStates / AtlasNetworkFailureEmpty.
// Label → WorkspaceEmptyStates+RetryLabel.swift

extension AtlasNetworkFailureEmpty {
    @ViewBuilder
    var retryButton: some View {
        let button = Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRetry()
        } label: {
            retryLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("tentar de novo")
        .accessibilityHint(retryHint)

        if let retryAccessibilityIdentifier {
            button.accessibilityIdentifier(retryAccessibilityIdentifier)
        } else {
            button
        }
    }
}
