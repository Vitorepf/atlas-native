import SwiftUI
import AtlasCore

// Arena refresh — peel de RootView+Lifecycle.

extension RootView {
    func rootLifecycleArena<Content: View>(_ content: Content) -> some View {
        content.task {
            if case .idle = session.arena.phase {
                await session.arena.refreshSummaryKeepingSnapshot()
            }
        }
    }
}
