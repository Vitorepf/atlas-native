import SwiftUI
import AtlasCore

// IDLE-COMPRESS body

// --- SearchView+A11y+Results.swift ---
extension SearchView {
    func spokenSearchResultsLabel() -> String {
        if isBrowsingRecent {
            let n = recentThreads.count
            if n == 0 { return "busca, sem recentes neste recorte" }
            return "busca, \(n) recente\(n == 1 ? "" : "s")"
        }
        let n = searchResults.count
        if n == 0 { return "busca, nada com \(trimmedQuery)" }
        return "busca, \(n) resultado\(n == 1 ? "" : "s") para \(trimmedQuery)"
    }
}

// --- SearchView+A11y+Shell.swift ---
extension SearchView {
    func spokenSearchShellLabel() -> String? {
        if showsLoadingShell { return "busca, carregando conversas" }
        if showsNetworkFailure { return "busca, offline" }
        return nil
    }
}

// --- SearchView+A11y.swift ---
extension SearchView {
    func spokenSearchScreenLabel() -> String {
        spokenSearchShellLabel() ?? spokenSearchResultsLabel()
    }

    static let searchScreenHint = "busca local nas conversas já carregadas na sessão"
}

// --- SearchView+A11yChrome.swift ---
extension SearchView {
    func searchA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(A11yID.searchScreen)
            .accessibilityLabel(spokenSearchScreenLabel())
            .accessibilityHint(Self.searchScreenHint)
            .onAppear { focused = true }
    }
}

// --- SearchView+BackgroundShell.swift ---
extension SearchView {
    var searchBackgroundShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            searchLayout
        }
    }
}

// --- SearchView+Header.swift ---
struct SearchViewHeader: View {
    @Binding var query: String
    @FocusState.Binding var focused: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            searchBackButton
            searchFieldCapsule
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 10)
    }
}

// --- SearchView+HeaderBack.swift ---
extension SearchViewHeader {
    var searchBackButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40).atlasGlassCircle()
        }
        .accessibilityLabel("voltar")
        .accessibilityHint("fecha a busca")
    }
}

// --- SearchView+HeaderClear+Action.swift ---
extension SearchViewHeader {
    func clearSearchQuery() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        query = ""
    }
}

// --- SearchView+HeaderClear.swift ---
extension SearchViewHeader {
    @ViewBuilder
    var searchClearButton: some View {
        if !query.isEmpty {
            searchClearA11y(
                Button(action: clearSearchQuery) {
                    searchClearIcon
                }
            )
        }
    }
}

// --- SearchView+HeaderClearA11y.swift ---
extension SearchViewHeader {
    func searchClearA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .accessibilityLabel("limpar busca")
            .accessibilityHint("remove o texto e volta aos recentes")
            .accessibilityIdentifier(A11yID.searchClear)
    }
}

// --- SearchView+HeaderClearIcon.swift ---
extension SearchViewHeader {
    var searchClearIcon: some View {
        Image(systemName: "xmark.circle.fill")
            .atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
    }
}

// --- SearchView+HeaderField.swift ---
extension SearchViewHeader {
    var searchFieldCapsule: some View {
        searchFieldLeading
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.surface)
                .overlay(Capsule().stroke(focused ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: focused)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: query.isEmpty)
    }
}

// --- SearchView+HeaderFieldLeading+FieldInput.swift ---
extension SearchViewHeader {
    var searchFieldInput: some View {
        ZStack(alignment: .leading) {
            searchFieldPlaceholder
            TextField("", text: $query)
                .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                .tint(AtlasTheme.accent).focused($focused)
                .submitLabel(.search)
                .accessibilityLabel(spokenFieldLabel)
                .accessibilityHint("filtra só conversas já carregadas na sessão")
                .accessibilityIdentifier(A11yID.searchField)
        }
    }
}

// --- SearchView+HeaderFieldLeading.swift ---
extension SearchViewHeader {
    var searchFieldLeading: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            searchFieldInput
            searchClearButton
        }
    }
}

// --- SearchView+HeaderFieldPlaceholder.swift ---
extension SearchViewHeader {
    var searchFieldPlaceholder: some View {
        Text("Buscar conversas")
            .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
            .opacity(query.isEmpty ? 1 : 0).allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

// --- SearchView+HeaderSpoken.swift ---
extension SearchViewHeader {
    var spokenFieldLabel: String {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "buscar conversas" }
        return "buscar conversas, \(trimmed)"
    }
}

// --- SearchView+List+RecentLoop.swift ---
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

// --- SearchView+List.swift ---
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

// --- SearchView+ListCaption.swift ---
extension SearchRecentSection {
    var recentCaption: some View {
        Text("RECENTES")
            .font(AtlasFont.mono(10, .semibold)).tracking(1.4)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("recentes, \(threads.count) conversa\(threads.count == 1 ? "" : "s") carregada\(threads.count == 1 ? "" : "s")")
            .accessibilityIdentifier(A11yID.searchRecentCaption)
    }
}

// --- SearchView+Miss.swift ---
struct SearchMissEmpty: View {
    let query: String
    let loadedThreadCount: Int

    private var headline: String {
        loadedThreadCount >= 100
            ? "“Nada com ‘\(query)’ nas 100 conversas mais recentes.”"
            : "“Nada com ‘\(query)’.”"
    }

    var body: some View {
        AtlasEditorialGlyphEmpty(
            headline: headline,
            accessibilityIdentifier: A11yID.searchEmpty
        )
    }
}

// --- SearchView+Query+Recent.swift ---
extension SearchView {
    /// Só threads já carregadas na sessão — zero placeholder ou sugestão inventada.
    var recentThreads: [AtlasAiThread] {
        Array(session.threads.prefix(12))
    }
}

// --- SearchView+Query+Trim.swift ---
extension SearchView {
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    var isBrowsingRecent: Bool { trimmedQuery.isEmpty }
}

// --- SearchView+QueryPhase+LoadingShell.swift ---
extension SearchView {
    var showsLoadingShell: Bool {
        guard session.threads.isEmpty else { return false }
        switch session.phase {
        case .idle, .loading: return true
        default: return false
        }
    }
}

// --- SearchView+QueryPhase+NetworkFailure.swift ---
extension SearchView {
    /// Sessão sem threads e load falhou → offline/rede, não silêncio nem «sem recentes».
    var showsNetworkFailure: Bool {
        guard session.threads.isEmpty else { return false }
        if case .failed = session.phase { return true }
        return false
    }
}

// --- SearchView+QueryResults.swift ---
extension SearchView {
    var searchResults: [AtlasAiThread] {
        let q = trimmedQuery.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        guard !q.isEmpty else { return [] }
        return session.threads.filter {
            $0.title.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .contains(q)
        }
    }
}

// --- SearchView+Results+ThreadLoop.swift ---
extension SearchResultsSection {
    /// Mesma régua da lista de Conversas: "novo" na maioria de 6+ linhas
    /// não discrimina — silencia em bloco.
    var newBadgeSaturated: Bool {
        results.count >= 6
            && results.lazy.filter(ConversationModel.hasNewerContent).count * 2 > results.count
    }

    @ViewBuilder
    var resultsThreadLoop: some View {
        let saturated = newBadgeSaturated
        ForEach(results) { t in
            SearchThreadLink(thread: t, reduceMotion: reduceMotion, newBadgeSuppressed: saturated)
            if t.id != results.last?.id {
                Divider().overlay(AtlasTheme.separator)
                    .padding(.leading, AtlasTheme.Space.screen + 36)
            }
        }
    }
}

// --- SearchView+Results.swift ---
struct SearchResultsSection: View {
    let results: [AtlasAiThread]
    let query: String
    let reduceMotion: Bool

    var body: some View {
        Group {
            resultsCaption
            resultsThreadLoop
        }
    }
}

// --- SearchView+ResultsCaption.swift ---
extension SearchResultsSection {
    var resultsCaption: some View {
        Text("\(results.count) resultado\(results.count == 1 ? "" : "s")")
            .font(AtlasFont.mono(10, .semibold)).tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("\(results.count) conversa\(results.count == 1 ? "" : "s") com ‘\(query)’")
            .accessibilityIdentifier(A11yID.searchResultsCaption)
    }
}

// --- SearchView+Scroll.swift ---
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

// --- SearchView+ScrollQuery.swift ---
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

// --- SearchView+ScrollShell+Loading.swift ---
extension SearchView {
    @ViewBuilder
    var searchLoadingShell: some View {
        WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
            .accessibilityIdentifier(A11yID.searchLoading)
    }
}

// --- SearchView+ScrollShell+Offline.swift ---
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

// --- SearchView+ScrollShell.swift ---
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

// --- SearchView+SearchLayout.swift ---
extension SearchView {
    var searchLayout: some View {
        VStack(spacing: 0) {
            SearchViewHeader(query: $query, focused: $focused)
            list
        }
    }
}

// --- SearchView+ThreadLink+Nav.swift ---
extension SearchThreadLink {
    var threadNavigationLink: some View {
        NavigationLink(value: Route.thread(id: ThreadID(thread.id), title: thread.title)) {
            ThreadRow(thread: thread, newBadgeSuppressed: newBadgeSuppressed)
        }
        .buttonStyle(.plain)
    }
}

// --- SearchView+ThreadLink+Transition.swift ---
extension SearchThreadLink {
    func threadLinkTransition<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(SearchThreadLink.spokenLabel(thread))
            .accessibilityHint("abre a conversa")
            .accessibilityIdentifier(A11yID.searchResult(thread.id))
            .transition(reduceMotion ? .opacity : .asymmetric(
                insertion: .opacity.combined(with: .offset(y: 6)),
                removal: .opacity
            ))
    }
}

// --- SearchView+ThreadLink.swift ---
struct SearchThreadLink: View {
    let thread: AtlasAiThread
    let reduceMotion: Bool
    var newBadgeSuppressed: Bool = false

    var body: some View {
        threadLinkTransition(threadNavigationLink)
    }
}

// --- SearchView+ThreadLinkSpoken.swift ---
extension SearchThreadLink {
    static func spokenLabel(_ thread: AtlasAiThread) -> String {
        var parts = [thread.title, "\(thread.messageCount) mensagens"]
        if TurnPresence.shared.runningTitles.contains(thread.title) {
            parts.append("executando")
        } else if ConversationModel.hasNewerContent(thread) {
            parts.append("novo desde a última visita")
        }
        return parts.joined(separator: ", ")
    }
}

