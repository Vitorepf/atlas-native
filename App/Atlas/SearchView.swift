import AtlasCore
import Foundation
import SwiftUI

// Cycle 044 fuse → SearchView.swift

// Busca REAL sobre as conversas (o dado já vive na sessão — filtro local,
// zero rede na casca). Sem query: recentes reais ou silêncio. Com query:
// título folded (caso+acento insensível). Offline ≠ vazio editorial.
struct SearchView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var query = ""
    @FocusState var focused: Bool

    var body: some View {
        searchA11yChrome(searchBackgroundShell)
    }
}

extension SearchView {
    var searchBackgroundShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            searchLayout
        }
    }
}

extension SearchView {
    var searchLayout: some View {
        VStack(spacing: 0) {
            SearchViewHeader(query: $query, focused: $focused)
            list
        }
    }
}

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

extension SearchViewHeader {
    var searchBackButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 44, height: 44).atlasGlassCircle()
                .contentShape(Circle())
        }
        .accessibilityLabel("voltar")
        .accessibilityHint("fecha a busca")
        .accessibilityAddTraits(.isButton)
    }
}

extension SearchViewHeader {
    func clearSearchQuery() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        query = ""
    }
}

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

extension SearchViewHeader {
    func searchClearA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .accessibilityLabel("limpar busca")
            .accessibilityHint("remove o texto e volta aos recentes")
            .accessibilityIdentifier(A11yID.searchClear)
            .accessibilityAddTraits(.isButton)
    }
}

extension SearchViewHeader {
    var searchClearIcon: some View {
        Image(systemName: "xmark.circle.fill")
            .atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
            .frame(width: 44, height: 44)
            .contentShape(Circle())
    }
}

extension SearchViewHeader {
    var searchFieldCapsule: some View {
        searchFieldLeading
            .padding(.horizontal, 14).padding(.vertical, 9)
            .frame(minHeight: 44) // HIG interactive minimum
            .background(Capsule().fill(AtlasTheme.surface)
                .overlay(Capsule().stroke(focused ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: focused)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: query.isEmpty)
    }
}

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

extension SearchViewHeader {
    var searchFieldPlaceholder: some View {
        Text("Buscar conversas")
            .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
            .opacity(query.isEmpty ? 1 : 0).allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

extension SearchViewHeader {
    var spokenFieldLabel: String {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "buscar conversas" }
        return "buscar conversas, \(trimmed)"
    }
}

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

extension SearchView {
    func spokenSearchShellLabel() -> String? {
        if showsLoadingShell { return "busca, carregando conversas" }
        if showsNetworkFailure { return "busca, offline" }
        return nil
    }
}

extension SearchView {
    func spokenSearchScreenLabel() -> String {
        spokenSearchShellLabel() ?? spokenSearchResultsLabel()
    }

    static let searchScreenHint = "busca local nas conversas já carregadas na sessão"
}

extension SearchView {
    func searchA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(A11yID.searchScreen)
            // Contain without fused screen label so field/results stay focusable.
            .accessibilityElement(children: .contain)
            .onAppear { focused = true }
    }
}

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

extension SearchResultsSection {
    var resultsCaption: some View {
        Text("\(results.count) resultado\(results.count == 1 ? "" : "s")")
            .font(.system(.caption, weight: .semibold)).tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("\(results.count) conversa\(results.count == 1 ? "" : "s") com ‘\(query)’")
            .accessibilityIdentifier(A11yID.searchResultsCaption)
    }
}

extension SearchView {
    /// Só threads já carregadas na sessão — zero placeholder ou sugestão inventada.
    var recentThreads: [AtlasAiThread] {
        Array(session.threads.prefix(12))
    }
}

extension SearchView {
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    var isBrowsingRecent: Bool { trimmedQuery.isEmpty }
}

extension SearchView {
    var showsLoadingShell: Bool {
        guard session.threads.isEmpty else { return false }
        switch session.phase {
        case .idle, .loading: return true
        default: return false
        }
    }
}

extension SearchView {
    var showsNetworkFailure: Bool {
        guard session.threads.isEmpty else { return false }
        if case .failed = session.phase { return true }
        return false
    }
}

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
            footnote: "tente outra frase · a busca olha títulos e trechos recentes",
            accessibilityIdentifier: A11yID.searchEmpty,
            spokenLabel: "\(headline) tente outra frase"
        )
    }
}

extension SearchThreadLink {
    var threadNavigationLink: some View {
        NavigationLink(value: Route.thread(id: ThreadID(thread.id), title: thread.title)) {
            ThreadRow(thread: thread, newBadgeSuppressed: newBadgeSuppressed, ownsAccessibility: false)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
        })
    }
}

extension SearchThreadLink {
    func threadLinkTransition<Content: View>(_ content: Content) -> some View {
        let running = TurnPresence.shared.runningTitles.contains(thread.title)
        return content
            .accessibilityLabel(SearchThreadLink.spokenLabel(thread))
            .accessibilityHint(running ? "Atlas executando nesta conversa" : "abre a conversa")
            .accessibilityAddTraits(
                running && !reduceMotion
                    ? [.isButton, .updatesFrequently]
                    : .isButton
            )
            .accessibilityIdentifier(A11yID.searchResult(thread.id))
            .transition(reduceMotion ? .opacity : .asymmetric(
                insertion: .opacity.combined(with: .offset(y: 6)),
                removal: .opacity
            ))
    }
}

struct SearchThreadLink: View {
    let thread: AtlasAiThread
    let reduceMotion: Bool
    var newBadgeSuppressed: Bool = false

    var body: some View {
        threadLinkTransition(threadNavigationLink)
    }
}

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
