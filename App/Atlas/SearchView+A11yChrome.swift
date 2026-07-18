import SwiftUI
import AtlasCore

// Search a11y chrome — peel de SearchView.

extension SearchView {
    func searchA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .navigationBarHidden(true)
            .atlasSwipeBack()
            .accessibilityIdentifier(A11yID.searchScreen)
            .accessibilityLabel(spokenSearchScreenLabel())
            .accessibilityHint(Self.searchScreenHint)
            .onAppear { focused = true }
    }
}
