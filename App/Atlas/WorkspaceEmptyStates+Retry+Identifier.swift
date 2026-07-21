import SwiftUI
import AtlasCore

// Identifier branch — peel de WorkspaceEmptyStates+Retry.

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
