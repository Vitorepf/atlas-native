import SwiftUI
import AtlasCore

// Busca REAL sobre as conversas (o dado já vive na sessão — filtro local,
// zero rede na casca). Sem query: recentes reais ou silêncio. Com query:
// título folded (caso+acento insensível). Offline ≠ vazio editorial.
struct SearchView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var query = ""
    @FocusState private var focused: Bool

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    private var isBrowsingRecent: Bool { trimmedQuery.isEmpty }

    /// Sessão sem threads e load falhou → offline/rede, não silêncio nem «sem recentes».
    private var showsNetworkFailure: Bool {
        guard session.threads.isEmpty else { return false }
        if case .failed = session.phase { return true }
        return false
    }

    private var showsLoadingShell: Bool {
        guard session.threads.isEmpty else { return false }
        switch session.phase {
        case .idle, .loading: return true
        default: return false
        }
    }

    /// Só threads já carregadas na sessão — zero placeholder ou sugestão inventada.
    private var recentThreads: [AtlasAiThread] {
        Array(session.threads.prefix(12))
    }

    private var searchResults: [AtlasAiThread] {
        let q = trimmedQuery.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        guard !q.isEmpty else { return [] }
        return session.threads.filter {
            $0.title.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .contains(q)
        }
    }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                SearchViewHeader(query: $query, focused: $focused)
                list
            }
        }
        .navigationBarHidden(true)
        .accessibilityIdentifier(A11yID.searchScreen)
        .onAppear { focused = true }
    }

    private var list: some View {
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
                } else if isBrowsingRecent {
                    if !recentThreads.isEmpty {
                        SearchRecentSection(threads: recentThreads, reduceMotion: reduceMotion)
                    }
                } else if searchResults.isEmpty {
                    SearchMissEmpty(query: trimmedQuery, loadedThreadCount: session.threads.count)
                } else {
                    SearchResultsSection(results: searchResults, query: trimmedQuery, reduceMotion: reduceMotion)
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
