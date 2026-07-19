import SwiftUI
import AtlasCore

// Arena refresh — peel de RootView+Lifecycle.

extension RootView {
    func rootLifecycleArena<Content: View>(_ content: Content) -> some View {
        content.task {
#if DEBUG
            if session.arena.installVisualScenarioIfRequested() {
                if path.isEmpty { path.append(Route.arena) }
                return
            }
#endif
            if case .idle = session.arena.phase {
                await session.arena.refreshSummaryKeepingSnapshot()
            }
        }
    }
}
