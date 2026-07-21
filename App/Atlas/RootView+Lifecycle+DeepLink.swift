import SwiftUI
import AtlasCore

// Deep link — peel de RootView+Lifecycle.

extension RootView {
    func rootLifecycleDeepLink<Content: View>(_ content: Content) -> some View {
        content.onOpenURL { handleDeepLink($0) }
    }
}
