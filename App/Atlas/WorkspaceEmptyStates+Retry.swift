import AtlasCore
import SwiftUI

// Cycle 039 fuse → WorkspaceEmptyStates+Retry.swift

extension AtlasNetworkFailureEmpty {
    @ViewBuilder
    func retryButtonWithIdentifier<Content: View>(_ button: Content) -> some View {
        if let retryAccessibilityIdentifier {
            button.accessibilityIdentifier(retryAccessibilityIdentifier)
        } else {
            button
        }
    }
}

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
