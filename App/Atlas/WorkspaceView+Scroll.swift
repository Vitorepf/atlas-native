import SwiftUI
import AtlasCore

/// Lista / loading / offline / empty — peel de WorkspaceView (régua ≤100).

extension WorkspaceView {
    var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if showsLoadingShell {
                    WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
                        .accessibilityIdentifier(A11yID.workspaceLoading)
                } else if showsNetworkFailure {
                    AtlasNetworkFailureEmpty(
                        kind: session.failureKind,
                        hasToken: session.hasToken,
                        host: session.host,
                        retryHint: "reconecta e recarrega conversas deste workspace",
                        retryAccessibilityIdentifier: A11yID.workspaceRetry,
                        accessibilityIdentifier: A11yID.workspaceOffline,
                        onRetry: { Task { await session.loadThreads() } }
                    )
                } else if threads.isEmpty {
                    WorkspaceEditorialEmpty(area: area, freeOnly: freeOnly, screenTitle: title)
                } else {
                    WorkspaceThreadsSection(
                        threads: threads,
                        area: area,
                        screenTitle: title,
                        reduceMotion: reduceMotion
                    )
                }
            }
            .padding(.bottom, 96)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: threads.map(\.id))
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }
}
