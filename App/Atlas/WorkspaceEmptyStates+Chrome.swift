import SwiftUI
import AtlasCore

// Network failure chrome — peel de WorkspaceEmptyStates.

extension AtlasNetworkFailureEmpty {
    func failureChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 44).padding(.top, topPadding)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(accessibilityIdentifier)
            .accessibilityLabel("\(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)). \(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))")
    }
}
