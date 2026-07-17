import SwiftUI
import AtlasCore

// Retry a11y chrome — peel de AtlasArenaView+FailureRetry.

extension AtlasArenaView {
    func networkFailureRetryA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .padding(.top, 4)
            .accessibilityLabel("tentar de novo")
            .accessibilityHint("reconecta ao servidor Atlas")
    }
}
