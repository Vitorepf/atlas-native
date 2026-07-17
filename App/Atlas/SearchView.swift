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
                header
                list
            }
        }
        .navigationBarHidden(true)
        .accessibilityIdentifier(A11yID.searchScreen)
        .onAppear { focused = true }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            .accessibilityLabel("voltar")

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                ZStack(alignment: .leading) {
                    Text("Buscar conversas")
                        .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
                        .opacity(query.isEmpty ? 1 : 0).allowsHitTesting(false)
                    TextField("", text: $query)
                        .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                        .tint(AtlasTheme.accent).focused($focused)
                        .submitLabel(.search)
                        .accessibilityLabel("buscar conversas")
                        .accessibilityHint(isBrowsingRecent
                            ? "digite para filtrar; sem texto mostra conversas recentes carregadas"
                            : "filtra pelos títulos das conversas já carregadas")
                        .accessibilityIdentifier(A11yID.searchField)
                }
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("limpar busca")
                    .accessibilityIdentifier(A11yID.searchClear)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.surface)
                .overlay(Capsule().stroke(focused ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1)))
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 10)
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
