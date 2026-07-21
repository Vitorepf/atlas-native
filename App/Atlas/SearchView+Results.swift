import AtlasCore
import SwiftUI

// Cycle 041 fuse → SearchView+Results.swift

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
            .accessibilityLabel(spokenSearchScreenLabel())
            .accessibilityHint(Self.searchScreenHint)
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
            accessibilityIdentifier: A11yID.searchEmpty
        )
    }
}

extension SearchThreadLink {
    var threadNavigationLink: some View {
        NavigationLink(value: Route.thread(id: ThreadID(thread.id), title: thread.title)) {
            ThreadRow(thread: thread, newBadgeSuppressed: newBadgeSuppressed)
        }
        .buttonStyle(.plain)
    }
}

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
