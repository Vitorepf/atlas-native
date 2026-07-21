import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: SearchSurface + SearchView entry fused

// MARK: - Surface

// MARK: - Host

// MARK: - Screen face · a11y

extension SearchView {
    /// WAVE-071: exclusive search face from published shell + counts.
    var searchScreenFace: SearchScreenFace {
        SearchJudgment.face(
            showsLoadingShell: showsLoadingShell,
            showsNetworkFailure: showsNetworkFailure,
            isBrowsingRecent: isBrowsingRecent,
            recentCount: recentThreads.count,
            resultCount: searchResults.count,
            trimmedQuery: trimmedQuery
        )
    }


}

extension SearchView {
    func searchA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(A11yID.searchScreen)
            .accessibilityLabel(SearchJudgment.spokenScreen(face: searchScreenFace, trimmedQuery: trimmedQuery))
            .accessibilityValue(searchScreenFace.productWord)
            .accessibilityHint(SearchJudgment.spokenScreenHint)
            .onAppear { focused = true }
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

// MARK: - Header

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
                .frame(width: 40, height: 40).atlasGlassCircle()
        }
        .accessibilityLabel(SearchJudgment.spokenBack)
        .accessibilityHint(SearchJudgment.spokenBackHint)
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
            .accessibilityLabel(SearchJudgment.spokenClear)
            .accessibilityHint(SearchJudgment.spokenClearHint)
            .accessibilityIdentifier(A11yID.searchClear)
    }
}

extension SearchViewHeader {
    var searchClearIcon: some View {
        Image(systemName: "xmark.circle.fill")
            .atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
    }
}

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

extension SearchViewHeader {
    var searchFieldInput: some View {
        ZStack(alignment: .leading) {
            searchFieldPlaceholder
            TextField("", text: $query)
                .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                .tint(AtlasTheme.accent).focused($focused)
                .submitLabel(.search)
                .accessibilityLabel(SearchListJudgment.spokenField(query: query))
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

// MARK: - Recent section

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
            .font(AtlasFont.mono(10, .semibold)).tracking(1.4)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(SearchListJudgment.spokenRecentCaption(count: threads.count))
            .accessibilityValue(SearchListFace.recent(threads.count).productWord)
            .accessibilityIdentifier(A11yID.searchRecentCaption)
    }
}

// MARK: - Body

// MARK: - Miss empty
struct SearchMissEmpty: View {
    let query: String
    let loadedThreadCount: Int

    private var headline: String {
        SearchListJudgment.missHeadline(query: query, loadedThreadCount: loadedThreadCount)
    }

    var body: some View {
        AtlasEditorialGlyphEmpty(
            headline: headline,
            accessibilityIdentifier: A11yID.searchEmpty
        )
        .accessibilityValue(SearchListFace.miss.productWord)
    }
}

extension SearchView {
    /// Só threads já carregadas na sessão — zero placeholder ou sugestão inventada.
    /// WAVE-032: live-first among recents.
// MARK: - Search query / face
    var recentThreads: [AtlasAiThread] {
        let head = Array(session.threads.prefix(12))
        return WorkspaceThreadJudgment.rank(head, remote: session.remoteLiveSessions)
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
    /// Sessão sem threads e load falhou → offline/rede, não silêncio nem «sem recentes».
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
        let filtered = session.threads.filter {
            $0.title.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .contains(q)
        }
        // WAVE-032: live-first parity with Workspace catalog.
        return WorkspaceThreadJudgment.rank(filtered, remote: session.remoteLiveSessions)
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

// MARK: - Results section
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
        Text(SearchListJudgment.resultsCaptionText(count: results.count))
            .font(AtlasFont.mono(10, .semibold)).tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(
                SearchListJudgment.spokenResultsCaption(count: results.count, query: query)
            )
            .accessibilityValue(SearchListFace.results(results.count).productWord)
            .accessibilityIdentifier(A11yID.searchResultsCaption)
    }
}

// MARK: - List shell
extension SearchView {
    var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                listShellContent
            }
            .padding(.bottom, 88)
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

extension SearchView {
    var searchLayout: some View {
        VStack(spacing: 0) {
            SearchViewHeader(query: $query, focused: $focused)
            list
        }
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
            .accessibilityLabel(SearchListJudgment.spokenRow(thread: thread))
            .accessibilityHint(SearchListJudgment.openThreadHint)
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

// MARK: - Route entry SearchView

struct SearchView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var query = ""
    @FocusState var focused: Bool
    @State var showingAsk = false
    @State var askDraft = ""
    @State var askThreadId: ThreadID?

    var body: some View {
        searchA11yChrome(searchBackgroundShell)
            .safeAreaInset(edge: .bottom, spacing: 0) { askPillDock }
            .sheet(isPresented: $showingAsk) { askConversationSheet }
    }
}

// MARK: - Agentic pill (WAVE-176)

extension SearchView {
    var askPillDock: some View {
        AgenticAskDock {
            AgenticPill(
                invite: SearchAskContext.invite,
                accessibilityId: A11yID.searchAskPill,
                accessibilityHintText: "Abre conversa com o contexto da busca"
            ) {
                askDraft = ""
                showingAsk = true
            }
        }
    }

    var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: "Busca",
            emptyPrompt: SearchAskContext.emptyPrompt(
                face: searchScreenFace,
                trimmedQuery: trimmedQuery
            ),
            emptySuggestions: SearchAskContext.emptySuggestions,
            taskKind: "search",
            workspace: nil,
            draft: askDraft,
            turnFacts: { [session, query] _ in
                // Capture live face inputs at ask time (session + query state).
                let trimmed = query.trimmingCharacters(in: .whitespaces)
                let browsing = trimmed.isEmpty
                let loading: Bool = {
                    guard session.threads.isEmpty else { return false }
                    switch session.phase {
                    case .idle, .loading: return true
                    default: return false
                    }
                }()
                let offline: Bool = {
                    guard session.threads.isEmpty else { return false }
                    if case .failed = session.phase { return true }
                    return false
                }()
                let recent = browsing
                    ? WorkspaceThreadJudgment.rank(
                        Array(session.threads.prefix(12)),
                        remote: session.remoteLiveSessions
                    ).count
                    : 0
                let results: Int = {
                    guard !trimmed.isEmpty else { return 0 }
                    let q = trimmed.folding(
                        options: [.caseInsensitive, .diacriticInsensitive],
                        locale: .current
                    )
                    return session.threads.filter {
                        $0.title.folding(
                            options: [.caseInsensitive, .diacriticInsensitive],
                            locale: .current
                        ).contains(q)
                    }.count
                }()
                return SearchAskContext.facts(
                    session: session,
                    showsLoadingShell: loading,
                    showsNetworkFailure: offline,
                    isBrowsingRecent: browsing,
                    recentCount: recent,
                    resultCount: results,
                    trimmedQuery: trimmed
                )
            },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .agenticAskSheetPresentation()
    }
}

// MARK: - SearchJudgment

// MARK: - SearchJudgment

// MARK: - Types

/// Exclusive Search screen face (WAVE-071).
enum SearchScreenFace: Equatable {
    case loading
    case offline
    case emptyRecent
    case emptyQuery
    case resultsRecent(Int)
    case resultsQuery(Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .offline: return "offline"
        case .emptyRecent: return "empty_recent"
        case .emptyQuery: return "empty_query"
        case .resultsRecent: return "results_recent"
        case .resultsQuery: return "results_query"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "carregando conversas"
        case .offline:
            return "offline"
        case .emptyRecent:
            return "sem recentes neste recorte"
        case .emptyQuery:
            return "nada com a consulta"
        case .resultsRecent(let n):
            return n == 1 ? "1 recente" : "\(n) recentes"
        case .resultsQuery(let n):
            return n == 1 ? "1 resultado" : "\(n) resultados"
        }
    }
}

// MARK: - Judgment

/// Pure search-screen grammar — face · spoken · pack.
enum SearchJudgment {

    static let spokenScreenHint = "busca local nas conversas já carregadas na sessão"
    static let spokenBack = "voltar"
    static let spokenBackHint = "fecha a busca"
    static let spokenClear = "limpar busca"
    static let spokenClearHint = "remove o texto e volta aos recentes"

    static func face(
        showsLoadingShell: Bool,
        showsNetworkFailure: Bool,
        isBrowsingRecent: Bool,
        recentCount: Int,
        resultCount: Int,
        trimmedQuery: String
    ) -> SearchScreenFace {
        if showsLoadingShell { return .loading }
        if showsNetworkFailure { return .offline }
        if isBrowsingRecent {
            if recentCount <= 0 { return .emptyRecent }
            return .resultsRecent(recentCount)
        }
        if resultCount <= 0 { return .emptyQuery }
        return .resultsQuery(resultCount)
    }

    static func spokenScreen(
        face: SearchScreenFace,
        trimmedQuery: String
    ) -> String {
        switch face {
        case .loading:
            return "busca, carregando conversas"
        case .offline:
            return "busca, offline"
        case .emptyRecent:
            return "busca, sem recentes neste recorte"
        case .emptyQuery:
            return "busca, nada com \(trimmedQuery)"
        case .resultsRecent(let n):
            return "busca, \(n) recente\(n == 1 ? "" : "s")"
        case .resultsQuery(let n):
            return "busca, \(n) resultado\(n == 1 ? "" : "s") para \(trimmedQuery)"
        }
    }

    static func packFacts(
        showsLoadingShell: Bool,
        showsNetworkFailure: Bool,
        isBrowsingRecent: Bool,
        recentCount: Int,
        resultCount: Int,
        trimmedQuery: String
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(
            showsLoadingShell: showsLoadingShell,
            showsNetworkFailure: showsNetworkFailure,
            isBrowsingRecent: isBrowsingRecent,
            recentCount: recentCount,
            resultCount: resultCount,
            trimmedQuery: trimmedQuery
        )
        facts.append("search_face: \(face.productWord)")
        if !trimmedQuery.isEmpty {
            facts.append("search_query: \(trimmedQuery)")
        }
        switch face {
        case .loading:
            absences.append("busca ainda carregando")
        case .offline:
            absences.append("busca offline")
        case .emptyRecent:
            absences.append("sem recentes neste recorte")
        case .emptyQuery:
            absences.append("consulta sem resultados")
        case .resultsRecent(let n):
            facts.append("search_recent_count: \(n)")
        case .resultsQuery(let n):
            facts.append("search_result_count: \(n)")
        }

        // WAVE-089: list organ pack (captions/rows/miss) — independent of screen face words.
        let list = SearchListJudgment.packFacts(
            isBrowsingRecent: isBrowsingRecent,
            recentCount: recentCount,
            resultCount: resultCount,
            trimmedQuery: trimmedQuery,
            screenIsBlocking: showsLoadingShell || showsNetworkFailure
        )
        facts.append(contentsOf: list.facts)
        absences.append(contentsOf: list.absences)
        return (facts, absences)
    }
}
// MARK: - SearchListJudgment

// MARK: - Types

/// Exclusive search list/row editorial face (WAVE-089).
/// Screen face stays WAVE-071; this organ is list captions + rows + miss.
enum SearchListFace: Equatable {
    case silence
    case recent(Int)
    case results(Int)
    case miss

    var productWord: String {
        switch self {
        case .silence: return "silence"
        case .recent(let n): return "recent(\(n))"
        case .results(let n): return "results(\(n))"
        case .miss: return "miss"
        }
    }

    var spokenFace: String {
        switch self {
        case .silence:
            return "lista em silêncio"
        case .recent(let n):
            let noun = n == 1 ? "recente" : "recentes"
            return "\(n) \(noun)"
        case .results(let n):
            let noun = n == 1 ? "resultado" : "resultados"
            return "\(n) \(noun)"
        case .miss:
            return "nada com a consulta"
        }
    }
}

// MARK: - Judgment

/// Pure search-list grammar — list face · field · captions · row · miss · pack.
enum SearchListJudgment {

    static let openThreadHint = "abre a conversa"
    static let fieldPlaceholder = "Buscar conversas"

    // MARK: Face

    static func listFace(
        isBrowsingRecent: Bool,
        recentCount: Int,
        resultCount: Int,
        trimmedQuery: String,
        screenIsBlocking: Bool
    ) -> SearchListFace {
        if screenIsBlocking { return .silence }
        if isBrowsingRecent {
            if recentCount <= 0 { return .silence }
            return .recent(recentCount)
        }
        if trimmedQuery.isEmpty { return .silence }
        if resultCount <= 0 { return .miss }
        return .results(resultCount)
    }

    // MARK: Field / captions

    static func spokenField(query: String) -> String {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "buscar conversas" }
        return "buscar conversas, \(trimmed)"
    }

    static func spokenRecentCaption(count: Int) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        let loaded = count == 1 ? "carregada" : "carregadas"
        return "recentes, \(count) \(noun) \(loaded)"
    }

    static func spokenResultsCaption(count: Int, query: String) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        return "\(count) \(noun) com ‘\(query)’"
    }

    static func resultsCaptionText(count: Int) -> String {
        "\(count) resultado\(count == 1 ? "" : "s")"
    }

    // MARK: Miss

    static func missHeadline(query: String, loadedThreadCount: Int) -> String {
        if loadedThreadCount >= 100 {
            return "“Nada com ‘\(query)’ nas 100 conversas mais recentes.”"
        }
        return "“Nada com ‘\(query)’.”"
    }

    // MARK: Row

    static func spokenRow(
        title: String,
        messageCount: Int,
        isRunning: Bool,
        hasNewer: Bool
    ) -> String {
        var parts = [title, "\(messageCount) mensagens"]
        if isRunning {
            parts.append("executando")
        } else if hasNewer {
            parts.append("novo desde a última visita")
        }
        return parts.joined(separator: ", ")
    }

    @MainActor
    static func spokenRow(thread: AtlasAiThread) -> String {
        spokenRow(
            title: thread.title,
            messageCount: thread.messageCount,
            isRunning: WorkspaceThreadJudgment.isRunning(thread: thread),
            hasNewer: ConversationModel.hasNewerContent(thread)
        )
    }

    // MARK: Pack

    static func packFacts(
        isBrowsingRecent: Bool,
        recentCount: Int,
        resultCount: Int,
        trimmedQuery: String,
        screenIsBlocking: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = listFace(
            isBrowsingRecent: isBrowsingRecent,
            recentCount: recentCount,
            resultCount: resultCount,
            trimmedQuery: trimmedQuery,
            screenIsBlocking: screenIsBlocking
        )
        facts.append("search_list_face: \(face.productWord)")
        switch face {
        case .silence:
            absences.append("lista de busca em silêncio (shell loading/offline ou vazia)")
        case .recent(let n):
            facts.append("search_list_recent: \(n)")
        case .results(let n):
            facts.append("search_list_results: \(n)")
            if !trimmedQuery.isEmpty {
                facts.append("search_list_query: \(trimmedQuery)")
            }
        case .miss:
            absences.append("consulta sem resultados na lista carregada")
            if !trimmedQuery.isEmpty {
                facts.append("search_list_query: \(trimmedQuery)")
            }
        }
        return (facts, absences)
    }
}
// MARK: - SearchAskContext

// MARK: - Invite · empty

/// Pack de ocasião Search — WAVE-176 agentic door (pill + pack).
/// Casca only · SearchJudgment.packFacts sovereignty · never invents threads.
enum SearchAskContext {
    static let invite = "o que você procura?"

    static var emptySuggestions: [String] {
        [
            "o que há de recente?",
            "quais conversas estão vivas?",
            "abre a thread que pede atenção",
        ]
    }

    static func emptyPrompt(
        face: SearchScreenFace,
        trimmedQuery: String
    ) -> String {
        switch face {
        case .loading:
            return "busca ainda carregando conversas — o que você quer achar?"
        case .offline:
            return "busca offline — reconecte ou pergunte o que falta"
        case .emptyRecent:
            return "sem recentes neste recorte — o que você procura?"
        case .emptyQuery:
            return trimmedQuery.isEmpty
                ? invite
                : "nada com «\(trimmedQuery)» — refine ou pergunte o recorte"
        case .resultsRecent(let n):
            return n == 1
                ? "1 recente listado — o que você quer saber?"
                : "\(n) recentes listados — o que você quer saber?"
        case .resultsQuery(let n):
            return n == 1
                ? "1 resultado para «\(trimmedQuery)» — o que fazer?"
                : "\(n) resultados para «\(trimmedQuery)» — o que fazer?"
        }
    }

    // MARK: - Facts pack

    @MainActor
    static func facts(
        session: AtlasSession,
        showsLoadingShell: Bool,
        showsNetworkFailure: Bool,
        isBrowsingRecent: Bool,
        recentCount: Int,
        resultCount: Int,
        trimmedQuery: String
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        facts.append("tela: busca")
        anchors.append("surface: search")

        let screen = SearchJudgment.packFacts(
            showsLoadingShell: showsLoadingShell,
            showsNetworkFailure: showsNetworkFailure,
            isBrowsingRecent: isBrowsingRecent,
            recentCount: recentCount,
            resultCount: resultCount,
            trimmedQuery: trimmedQuery
        )
        facts.append(contentsOf: screen.facts)
        absences.append(contentsOf: screen.absences)

        // Live among listed threads (recents or results) — honesty only.
        let listed: [AtlasAiThread]
        if isBrowsingRecent {
            listed = Array(session.threads.prefix(12))
        } else if !trimmedQuery.isEmpty {
            let q = trimmedQuery.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            listed = session.threads.filter {
                $0.title.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                    .contains(q)
            }
        } else {
            listed = []
        }
        let ranked = WorkspaceThreadJudgment.rank(listed, remote: session.remoteLiveSessions)
        let liveAmong = ranked.filter { thread in
            session.remoteLiveSessions.contains { $0.threadId == ThreadID(thread.id) }
                || TurnPresence.shared.liveSessions.contains { $0.threadId == ThreadID(thread.id) }
        }
        if !liveAmong.isEmpty {
            facts.append("search_live_in_list: \(liveAmong.count)")
            for t in liveAmong.prefix(3) {
                anchors.append("live · \(t.title)")
            }
        } else if !listed.isEmpty {
            absences.append("nenhuma thread viva no recorte listado da busca")
        }

        let empty = ConversationEmptyJudgment.packFacts(
            prompt: emptyPrompt(
                face: SearchJudgment.face(
                    showsLoadingShell: showsLoadingShell,
                    showsNetworkFailure: showsNetworkFailure,
                    isBrowsingRecent: isBrowsingRecent,
                    recentCount: recentCount,
                    resultCount: resultCount,
                    trimmedQuery: trimmedQuery
                ),
                trimmedQuery: trimmedQuery
            ),
            suggestions: emptySuggestions,
            isHomePartida: false,
            hasWorkspaces: !session.workspaces.isEmpty
        )
        facts.append(contentsOf: empty.facts)
        absences.append(contentsOf: empty.absences)

        let partida = PartidaCanDoJudgment.search(
            liveInList: liveAmong.count,
            isOffline: showsNetworkFailure,
            isLoading: showsLoadingShell
        )
        absences.append(contentsOf: partida.absences)

        return AgenticOccasionPack(
            surface: "search",
            subject: trimmedQuery.isEmpty ? "busca · recentes" : "busca · «\(trimmedQuery)»",
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: partida.canDo
        ).render()
    }
}

// MARK: - LiveTimeline

// MARK: - Timeline host

func activityIconIntent(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .understanding: return "text.magnifyingglass"
    case .context: return "square.stack.3d.up"
    case .planning: return "list.bullet.rectangle"
    case .permission: return "lock.shield"
    case .reasoning: return "brain"
    default: return nil
    }
}

func activityIconTerminal(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .completed: return "checkmark.circle.fill"
    case .warning: return "exclamationmark.triangle.fill"
    case .progress: return "ellipsis.circle"
    default: return nil
    }
}

func activityIconTool(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .executing: return "chevron.left.forwardslash.chevron.right"
    case .reading: return "doc.text"
    case .editing: return "pencil.line"
    case .verifying: return "checkmark.seal"
    case .evidence: return "tray.full"
    default: return nil
    }
}

func activityIcon(_ kind: AtlasAgentActivity.Kind) -> String {
    activityIconIntent(kind)
        ?? activityIconTool(kind)
        ?? activityIconTerminal(kind)
        ?? "ellipsis.circle"
}

// MARK: - Filter chrome

extension TimelineReadFilter {
    func applyAllOrP90(to rows: [NarrativeRow]) -> [NarrativeRow] {
        switch self {
        case .all:
            return rows
        case .p90:
            return rows.filter(\.isP90)
        default:
            return rows
        }
    }
}

extension TimelineReadFilter {
    func applyStyleFilter(to rows: [NarrativeRow]) -> [NarrativeRow]? {
        switch self {
        case .intent:
            return rows.filter { $0.style == .intent }
        case .tools:
            return rows.filter { $0.style == .single }
        default:
            return nil
        }
    }
}

extension TimelineReadFilter {
    func apply(to rows: [NarrativeRow]) -> [NarrativeRow] {
        if let styled = applyStyleFilter(to: rows) { return styled }
        return applyAllOrP90(to: rows)
    }
}

extension TimelineFilterChips {
    func filterChipA11y<Content: View>(
        _ content: Content,
        option: TimelineReadFilter,
        active: Bool,
        count: Int
    ) -> some View {
        content
            .accessibilityLabel(LiveTimelineFilterJudgment.spokenFilterChip(
                filter: option,
                count: count,
                active: active,
                silent: active && filterSilence
            ))
            .accessibilityHint(LiveTimelineFilterJudgment.filterHint)
            .accessibilityAddTraits(active ? .isSelected : [])
            .accessibilityIdentifier(A11yID.liveTimelineFilter(option.rawValue))
    }
}

extension TimelineFilterChips {
    func filterChipAction(_ option: TimelineReadFilter) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
            filter = option
        }
    }
}

extension TimelineFilterChips {
    func filterChipButton(_ option: TimelineReadFilter, active: Bool, count: Int) -> some View {
        filterChipA11y(
            Button {
                filterChipAction(option)
            } label: {
                chipLabel(option, active: active)
            }
            .buttonStyle(.plain),
            option: option,
            active: active,
            count: count
        )
    }
}

extension TimelineFilterChips {
    func chipLabel(_ option: TimelineReadFilter, active: Bool) -> some View {
        Text(option.label)
            .font(AtlasFont.mono(9))
            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.bgRecessed))
            .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
    }
}

extension TimelineFilterChips {
    @ViewBuilder
    var filterChipLoop: some View {
        ForEach(TimelineReadFilter.allCases) { option in
            let active = option == filter
            let count = option.apply(to: baseRows).count
            filterChipButton(option, active: active, count: count)
        }
    }
}

extension TimelineReadFilter {
    var label: String {
        switch self {
        case .all: return "todos"
        case .intent: return "intenção"
        case .tools: return "ferramentas"
        case .p90: return "p90"
        }
    }
}

enum TimelineReadFilter: String, CaseIterable, Identifiable {
    case all
    case intent
    case tools
    case p90

    var id: String { rawValue }
}

struct TimelineFilterChips: View {
    @Binding var filter: TimelineReadFilter
    var baseRows: [NarrativeRow]
    var reduceMotion: Bool = false
    var filterSilence: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            filterChipLoop
        }
        .padding(.leading, 20)
        .accessibilityIdentifier(A11yID.liveTimelineFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: filter)
    }
}

// MARK: - LiveTimelineFilterJudgment

// MARK: - Types

/// Exclusive timeline read-filter face (WAVE-075) — chrono order sacred.
enum LiveTimelineFilterFace: Equatable {
    /// No filter applied (all).
    case open
    /// Filter selected and has matching steps.
    case active
    /// Filter selected but zero matching steps (silence surface).
    case silent

    var productWord: String {
        switch self {
        case .open: return "open"
        case .active: return "active"
        case .silent: return "silent"
        }
    }

    var spokenFace: String {
        switch self {
        case .open: return "filtro aberto"
        case .active: return "filtro ativo"
        case .silent: return "filtro sem passos"
        }
    }
}

// MARK: - Judgment

/// Pure timeline read-filter grammar — face · spoken · pack.
/// Does **not** reorder narrative (chrono sagrado · WAVE-042/044).
enum LiveTimelineFilterJudgment {

    static let filterHint = "altera quais passos da orquestra são exibidos"

    static func face(
        filter: TimelineReadFilter,
        matchCount: Int,
        isActive: Bool
    ) -> LiveTimelineFilterFace {
        if !isActive || filter == .all {
            return .open
        }
        if matchCount <= 0 { return .silent }
        return .active
    }

    static func spokenSectionLabel(stepCount: Int) -> String {
        "orquestra ao vivo, \(stepCount) passo\(stepCount == 1 ? "" : "s")"
    }

    static func spokenFilterChip(
        filter: TimelineReadFilter,
        count: Int,
        active: Bool,
        silent: Bool
    ) -> String {
        "filtrar timeline por \(filter.label), \(count) passo\(count == 1 ? "" : "s")"
            + spokenFilterChipSuffix(active: active, silent: silent)
    }

    static func spokenFilterChipSuffix(active: Bool, silent: Bool) -> String {
        var suffix = ""
        if active { suffix += ", selecionado" }
        if silent { suffix += ", nenhum passo neste filtro" }
        return suffix
    }

    static func spokenFilterSilenceSurface(
        filter: TimelineReadFilter,
        totalSteps: Int
    ) -> String {
        "orquestra ao vivo, filtro \(filter.label), nenhum dos \(totalSteps) passos corresponde"
    }

    static func spokenRow(
        row: NarrativeRow,
        index: Int,
        total: Int,
        isCurrent: Bool
    ) -> String {
        var parts = ["passo \(index + 1) de \(total)", row.title]
        if let detail = row.detail, !detail.isEmpty { parts.append(detail) }
        if let duration = row.durationMs {
            parts.append("duração \(humanDuration(duration))")
            if row.isP90 { parts.append("acima do p90") }
        }
        if isCurrent { parts.append("passo atual da orquestra") }
        return parts.joined(separator: ", ")
    }

    static func rowValue(index: Int, total: Int, isCurrent: Bool) -> String {
        isCurrent
            ? "passo \(index + 1) de \(total), em andamento"
            : "passo \(index + 1) de \(total)"
    }

    static func packFacts(
        filter: TimelineReadFilter,
        matchCount: Int,
        totalSteps: Int,
        isActive: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(filter: filter, matchCount: matchCount, isActive: isActive)
        facts.append("timeline_filter_face: \(face.productWord)")
        facts.append("timeline_filter: \(filter.rawValue)")
        facts.append("timeline_filter_matches: \(matchCount)")
        facts.append("timeline_steps_total: \(totalSteps)")
        if face == .silent {
            absences.append("filtro sem passos correspondentes")
        }
        return (facts, absences)
    }

    /// WAVE-174: pack honesty for mid-thread — chip filter is @State local to LiveTimeline.
    static func packFactsOpenRecorte(totalSteps: Int) -> (facts: [String], absences: [String]) {
        var pack = packFacts(
            filter: .all,
            matchCount: totalSteps,
            totalSteps: totalSteps,
            isActive: false
        )
        pack.absences.append("filtro de leitura da timeline é local à UI — pack usa recorte aberto")
        return pack
    }
}

// MARK: - LiveTimelineNarrativeJudgment

// MARK: - Types

/// Exclusive live narrative face (WAVE-044). Chrono order stays sacred.
enum LiveTimelineNarrativeFace: Equatable {
    case empty
    case live(Int)
    case filterSilence(filter: TimelineReadFilter, total: Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .live: return "live"
        case .filterSilence: return "filter_silence"
        }
    }

    var kicker: String {
        switch self {
        case .empty: return "Narrativa"
        case .live: return "Narrativa viva"
        case .filterSilence: return "Filtro em silêncio"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem passos de narrativa"
        case .live(let n):
            return n == 1 ? "1 passo na narrativa" : "\(n) passos na narrativa"
        case .filterSilence(let filter, let total):
            return "filtro \(filter.label) em silêncio, \(total) passos na obra completa"
        }
    }
}

// MARK: - Judgment

/// Pure narrative face grammar — never re-ranks rows.
enum LiveTimelineNarrativeJudgment {

    static func face(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> LiveTimelineNarrativeFace {
        if baseRows.isEmpty { return .empty }
        if filteredRows.isEmpty, filter != .all {
            return .filterSilence(filter: filter, total: baseRows.count)
        }
        return .live(filteredRows.count)
    }

    static func summaryLine(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> String {
        switch face(baseRows: baseRows, filteredRows: filteredRows, filter: filter) {
        case .empty:
            return "sem passos"
        case .live(let n):
            let intents = filteredRows.filter { $0.style == .intent }.count
            if filter == .all {
                return intents > 0
                    ? "\(n) passos · \(intents) intenção"
                    : "\(n) passos"
            }
            return "\(filter.label) · \(n) passos"
        case .filterSilence(let filter, let total):
            return "\(filter.label) · 0 de \(total)"
        }
    }

    static func spokenSection(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> String {
        let face = face(baseRows: baseRows, filteredRows: filteredRows, filter: filter)
        switch face {
        case .empty:
            return "narrativa da execução, \(face.spokenFace)"
        case .live:
            return "narrativa da execução, \(face.spokenFace), \(summaryLine(baseRows: baseRows, filteredRows: filteredRows, filter: filter))"
        case .filterSilence:
            return "narrativa da execução, \(face.spokenFace)"
        }
    }

    static func packFacts(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(baseRows: baseRows, filteredRows: filteredRows, filter: filter)
        facts.append("timeline_face: \(face.productWord)")
        facts.append("filter: \(filter.rawValue)")
        facts.append(summaryLine(baseRows: baseRows, filteredRows: filteredRows, filter: filter))
        if baseRows.isEmpty {
            absences.append("sem atividades publicadas na narrativa")
            return (facts, absences)
        }
        facts.append("base_steps: \(baseRows.count)")
        facts.append("filtered_steps: \(filteredRows.count)")
        let intents = baseRows.filter { $0.style == .intent }.count
        facts.append("intent_style: \(intents)")
        if case .filterSilence = face {
            absences.append("filtro \(filter.label) sem linhas — obra ainda tem \(baseRows.count) passos")
        }
        return (facts, absences)
    }

    /// WAVE-174: mid-thread pack from published activities (filter UI is local — open recorte).
    static func packFacts(from activities: [AtlasAgentActivity]) -> (facts: [String], absences: [String]) {
        let base = narrativeRows(from: activities)
        return packFacts(baseRows: base, filteredRows: base, filter: .all)
    }
}

// MARK: - LiveTimelineNarrativeRow

// MARK: - Row

// MARK: - LiveTimelineNarrativeRow

struct NarrativeRow: Identifiable, Equatable {
    enum Style { case intent, single }
    let id: String
    let style: Style
    let title: String
    let detail: String?
    let occurredAt: Date?
    var durationMs: Int? = nil
    var isP90: Bool = false
}

extension NarrativeRowView {
    var narrativeSpine: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(isCurrent ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.4))
                .frame(width: 7, height: 7)
                .opacity(isCurrent && pulse && !reduceMotion ? 0.4 : 1)
                .padding(.top, 5)
            if !isLast {
                Rectangle()
                    .fill(AtlasTheme.accent.opacity(0.22))
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 10)
        .accessibilityHidden(true)
    }
}

extension NarrativeRowView {
    var narrativeTextStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(row.title)
                .font(row.style == .intent ? .system(.footnote) : .system(.caption))
                .foregroundStyle(row.style == .intent
                    ? (isCurrent ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                    : AtlasTheme.textTertiary)
                .lineLimit(row.style == .intent ? 3 : 2)
                .accessibilityHidden(true)
            narrativeDetailLine
            narrativeDurationMeta
        }
        .padding(.bottom, 10)
    }
}

extension NarrativeRowView {
    var currentTraits: AccessibilityTraits {
        guard isCurrent else { return [] }
        return reduceMotion ? .isSelected : [.isSelected, .updatesFrequently]
    }
}

// MARK: - LiveTimelineNarrativeRowChrome

extension LiveTimeline {
    @ViewBuilder
    var filterSilenceSurface: some View {
        if showsFilterChips {
            VStack(alignment: .leading, spacing: 8) {
                narrativeFaceChrome
                filterSilenceA11y(
                    TimelineFilterChips(filter: $filter,
                                        baseRows: baseRows,
                                        reduceMotion: reduceMotion,
                                        filterSilence: filterSilence)
                )
            }
        }
    }
}

extension LiveTimeline {
    var timelineSurface: some View {
        VStack(alignment: .leading, spacing: 8) {
            narrativeFaceChrome
            if showsFilterChips {
                TimelineFilterChips(filter: $filter,
                                    baseRows: baseRows,
                                    reduceMotion: reduceMotion,
                                    filterSilence: false)
            }
            timelineScroll
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            LiveTimelineNarrativeJudgment.spokenSection(
                baseRows: baseRows,
                filteredRows: rows,
                filter: filter
            )
        )
        .accessibilityIdentifier(A11yID.liveTimeline)
    }
}

struct LiveTimeline: View {
    let activities: [AtlasAgentActivity]
    let reduceMotion: Bool
    @State var filter: TimelineReadFilter = .all

    var body: some View {
        timelineBody
    }
}

func annotateNarrativeDurations(_ rows: inout [NarrativeRow]) {
    guard rows.count > 1 else { return }
    for index in rows.indices.dropLast() {
        guard let start = rows[index].occurredAt,
              let end = rows[rows.index(after: index)].occurredAt else { continue }
        rows[index].durationMs = max(0, Int(end.timeIntervalSince(start) * 1000))
    }
    annotateNarrativeP90(&rows)
}

func isNarrativeIntentKind(_ kind: AtlasAgentActivity.Kind) -> Bool {
    [.understanding, .planning, .reasoning, .permission,
     .completed, .warning, .evidence, .verifying].contains(kind)
}

func annotateNarrativeP90(_ rows: inout [NarrativeRow]) {
    let durations = rows.compactMap(\.durationMs).sorted()
    guard !durations.isEmpty else { return }
    let p90Index = min(durations.count - 1, Int(ceil(Double(durations.count) * 0.9)) - 1)
    let threshold = durations[max(0, p90Index)]
    guard threshold > 0 else { return }
    for index in rows.indices {
        rows[index].isP90 = (rows[index].durationMs ?? 0) >= threshold
    }
}

extension LiveTimeline {
    @ViewBuilder
    var timelineBody: some View {
        if baseRows.isEmpty {
            EmptyView()
        } else if rows.isEmpty {
            filterSilenceSurface
        } else {
            timelineSurface
        }
    }
}

extension NarrativeRowView {
    var narrativeBody: some View {
        HStack(alignment: .top, spacing: 10) {
            narrativeSpine
            narrativeTextStack
            Spacer(minLength: 0)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDetailLine: some View {
        if let detail = row.detail, !detail.isEmpty {
            Text(detail).font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(row.style == .intent ? 2 : 1)
                .truncationMode(.middle)
                .accessibilityHidden(true)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeP90Badge: some View {
        if row.isP90 {
            Text("p90")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.domOperacional)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDurationChip: some View {
        if let duration = row.durationMs {
            HStack(spacing: 5) {
                Text("Δ \(humanDuration(duration))")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(row.isP90 ? AtlasTheme.domOperacional : AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                narrativeP90Badge
            }
            .accessibilityHidden(true)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDurationMeta: some View {
        narrativeDurationChip
    }
}

extension NarrativeRowView {
    func narrativePulseLifecycle() -> some View {
        narrativeA11y
            .onAppear {
                if isCurrent && !reduceMotion {
                    withAnimation(AtlasMotion.breath(0.9)) { pulse = true }
                }
            }
            .onChange(of: isCurrent) { _, now in if !now { pulse = false } }
    }
}

// MARK: - Row view

struct NarrativeRowView: View {
    let row: NarrativeRow
    let index: Int
    let total: Int
    let isCurrent: Bool
    let isLast: Bool
    let reduceMotion: Bool
    @State var pulse = false

    var body: some View {
        narrativePulseLifecycle()
    }
}

extension LiveTimeline {
    var baseRows: [NarrativeRow] { narrativeRows(from: activities) }
    var rows: [NarrativeRow] { filter.apply(to: baseRows) }
    var showsFilterChips: Bool { baseRows.count > 2 }
    var filterSilence: Bool { showsFilterChips && filter != .all && rows.isEmpty }
}

func narrativeRowMap(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    activities.map { activity in
        NarrativeRow(
            id: activity.id,
            style: isNarrativeIntentKind(activity.kind) ? .intent : .single,
            title: activity.title,
            detail: activity.detail,
            occurredAt: AtlasTime.date(activity.occurredAt)
        )
    }
}

func narrativeRows(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    var rows = narrativeRowMap(from: activities)
    annotateNarrativeDurations(&rows)
    return rows
}

// WAVE-136 NarrativeRowView peels from LiveTimeline host
extension NarrativeRowView {
    var narrativeA11y: some View {
        narrativeBody
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(LiveTimelineFilterJudgment.spokenRow(row: row,
                                                           index: index,
                                                           total: total,
                                                           isCurrent: isCurrent))
            .accessibilityValue(LiveTimelineFilterJudgment.rowValue(index: index, total: total, isCurrent: isCurrent))
            .accessibilityAddTraits(currentTraits)
    }
}

extension LiveTimeline {
    func timelineScrollToLast(_ proxy: ScrollViewProxy) {
        guard let last = rows.last?.id else { return }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            proxy.scrollTo(last, anchor: .bottom)
        }
    }
}

extension LiveTimeline {
    var timelineScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                timelineRows
            }
            .frame(maxHeight: min(CGFloat(rows.count) * 34 + 12, 232))
            .scrollIndicators(.hidden)
            .onChange(of: rows.count) { timelineScrollToLast(proxy) }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: rows.count)
        }
    }
}

extension LiveTimeline {
    var timelineRows: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { idx, row in
                NarrativeRowView(row: row,
                                 index: idx,
                                 total: rows.count,
                                 isCurrent: idx == rows.count - 1,
                                 isLast: idx == rows.count - 1,
                                 reduceMotion: reduceMotion)
                    .id(row.id)
                    .transition(reduceMotion ? .opacity
                                : .move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.trailing, 4)
    }
}

extension LiveTimeline {
    func filterSilenceA11y<V: View>(_ content: V) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(LiveTimelineFilterJudgment.spokenFilterSilenceSurface(filter: filter,
                                                                            totalSteps: baseRows.count))
            .accessibilityValue(
                LiveTimelineFilterJudgment.face(
                    filter: filter,
                    matchCount: rows.count,
                    isActive: true
                ).productWord
            )
            .accessibilityIdentifier(A11yID.liveTimelineFilterSilence)
    }
}

extension LiveTimeline {
    /// WAVE-044: exclusive narrative face (chrono order unchanged).
    var narrativeFace: LiveTimelineNarrativeFace {
        LiveTimelineNarrativeJudgment.face(
            baseRows: baseRows,
            filteredRows: rows,
            filter: filter
        )
    }

    @ViewBuilder
    var narrativeFaceChrome: some View {
        switch narrativeFace {
        case .empty:
            EmptyView()
        case .live, .filterSilence:
            HStack(spacing: 6) {
                Text(narrativeFace.kicker)
                    .font(AtlasFont.mono(9))
                    .tracking(0.7)
                    .foregroundStyle(
                        narrativeFace.productWord == "filter_silence"
                            ? AtlasTheme.textTertiary
                            : AtlasTheme.accent
                    )
                Text(LiveTimelineNarrativeJudgment.summaryLine(
                    baseRows: baseRows,
                    filteredRows: rows,
                    filter: filter
                ))
                .font(AtlasFont.serif(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                Spacer(minLength: 0)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(narrativeFace.spokenFace)
            .accessibilityIdentifier(A11yID.liveTimelineFace)
        }
    }
}
