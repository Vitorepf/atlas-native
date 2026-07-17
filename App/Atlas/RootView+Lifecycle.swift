import SwiftUI
import AtlasCore

// Root lifecycle tasks — peel de RootView.

extension RootView {
    func rootLifecycleChrome<Content: View>(_ content: Content) -> some View {
        content
            .tint(AtlasTheme.accent)
            .onAppear { registerNightlyOpen() }
            .task { if session.phase == .idle { await session.loadThreads() } }
            .task {
                // A linha CÓDIGO só fala com dado real: sem resposta, ela cala.
                let hub = codeHub ?? AtlasCodeHubModel(client: session.client)
                codeHub = hub
                await hub.refresh()
            }
            .task {
                if case .idle = session.arena.phase {
                    await session.arena.refreshSummaryKeepingSnapshot()
                }
            }
            .onOpenURL { handleDeepLink($0) }
    }
}
