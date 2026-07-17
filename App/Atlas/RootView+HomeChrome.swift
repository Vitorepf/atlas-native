import SwiftUI
import AtlasCore

// Root home nav chrome — peel de RootView+HomeStack.

extension RootView {
    func rootHomeNavChrome<Content: View>(_ content: Content) -> some View {
        content
            .navigationBarHidden(true)
            .accessibilityIdentifier(A11yID.homeScreen)
            .accessibilityLabel(homeScreenSpokenLabel())
            .accessibilityHint(homeScreenSpokenHint())
            .navigationDestination(for: Route.self) { rootDestination(for: $0) }
    }
}
