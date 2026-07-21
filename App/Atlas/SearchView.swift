import SwiftUI
import AtlasCore

// IDLE-COMPRESS host · WAVE-176 agentic pill dock

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
