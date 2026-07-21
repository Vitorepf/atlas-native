import SwiftUI
import AtlasCore

// Tint + nightly bootstrap — peel de RootView+Lifecycle.

extension RootView {
    func rootLifecycleTintAppear<Content: View>(_ content: Content) -> some View {
        content
            .tint(AtlasTheme.accent)
            .onAppear { registerNightlyOpen() }
    }
}
