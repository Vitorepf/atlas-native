import SwiftUI
import AtlasCore

// Threads task — peel de RootView+Lifecycle.

extension RootView {
    func rootLifecycleThreads<Content: View>(_ content: Content) -> some View {
        content.task { if session.phase == .idle { await session.loadThreads() } }
    }
}
