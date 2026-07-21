import AtlasCore
import SwiftUI

// Cycle 031 fuse → SearchView+Scroll.swift

extension SearchView {
    var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                listShellContent
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

extension SearchView {
    @ViewBuilder
    var listQueryContent: some View {
        if isBrowsingRecent {
            if !recentThreads.isEmpty {
                SearchRecentSection(threads: recentThreads, reduceMotion: reduceMotion)
            }
        } else if searchResults.isEmpty {
            SearchMissEmpty(query: trimmedQuery, loadedThreadCount: session.threads.count)
        } else {
            SearchResultsSection(results: searchResults, query: trimmedQuery, reduceMotion: reduceMotion)
        }
    }
}

extension SearchView {
    @ViewBuilder
    var searchLoadingShell: some View {
        WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
            .accessibilityIdentifier(A11yID.searchLoading)
    }
}

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

extension SearchView {
    @ViewBuilder
    var listShellContent: some View {
        if showsLoadingShell {
            searchLoadingShell
        } else if showsNetworkFailure {
            searchOfflineShell
        } else {
            listQueryContent
        }
    }
}

extension SearchRecentSection {
    /// Mesma régua da lista de Conversas: saturado silencia em bloco.
    var newBadgeSaturated: Bool {
        threads.count >= 6
            && threads.lazy.filter(ConversationModel.hasNewerContent).count * 2 > threads.count
    }

    @ViewBuilder
    var recentThreadLoop: some View {
        let saturated = newBadgeSaturated
        ForEach(threads) { t in
            SearchThreadLink(thread: t, reduceMotion: reduceMotion, newBadgeSuppressed: saturated)
            if t.id != threads.last?.id {
                Divider().overlay(AtlasTheme.separator)
                    .padding(.leading, AtlasTheme.Space.screen + 36)
            }
        }
    }
}

struct SearchRecentSection: View {
    let threads: [AtlasAiThread]
    let reduceMotion: Bool

    var body: some View {
        Group {
            recentCaption
            recentThreadLoop
        }
    }
}

extension SearchRecentSection {
    var recentCaption: some View {
        Text("RECENTES")
            .font(.system(.caption, weight: .semibold)).tracking(1.4)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("recentes, \(threads.count) conversa\(threads.count == 1 ? "" : "s") carregada\(threads.count == 1 ? "" : "s")")
            .accessibilityIdentifier(A11yID.searchRecentCaption)
    }
}
