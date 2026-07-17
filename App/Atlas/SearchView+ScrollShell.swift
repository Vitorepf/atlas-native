import SwiftUI
import AtlasCore

// Loading / offline shells — peel de SearchView+Scroll.

extension SearchView {
    @ViewBuilder
    var listShellContent: some View {
        if showsLoadingShell {
            WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
                .accessibilityIdentifier(A11yID.searchLoading)
        } else if showsNetworkFailure {
            AtlasNetworkFailureEmpty(
                kind: session.failureKind,
                hasToken: session.hasToken,
                host: session.host,
                topPadding: 56,
                retryHint: "reconecta e recarrega conversas para buscar",
                accessibilityIdentifier: A11yID.searchOffline,
                onRetry: { Task { await session.loadThreads() } }
            )
        } else {
            listQueryContent
        }
    }
}
