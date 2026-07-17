import SwiftUI
import AtlasCore

/// Lista / loading / offline / miss — peel de SearchView (régua ≤100).
/// Query content → SearchView+ScrollQuery.swift

extension SearchView {
    var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
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
            .padding(.bottom, 40)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: trimmedQuery)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: session.threads.map(\.id))
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .refreshable { await session.loadThreads() }
    }
}
