import SwiftUI
import AtlasCore

// Offline shell — peel de SearchView+ScrollShell.

extension SearchView {
    @ViewBuilder
    var searchOfflineShell: some View {
        AtlasNetworkFailureEmpty(
            kind: session.failureKind,
            hasToken: session.hasToken,
            host: session.host,
            topPadding: 56,
            retryHint: "reconecta e recarrega conversas para buscar",
            accessibilityIdentifier: A11yID.searchOffline,
            onRetry: { Task { await session.loadThreads() } }
        )
    }
}
