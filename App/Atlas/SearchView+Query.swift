import SwiftUI
import AtlasCore

// Query / results helpers — peel de SearchView.
// Phase → SearchView+QueryPhase.swift

extension SearchView {
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    var isBrowsingRecent: Bool { trimmedQuery.isEmpty }

    /// Só threads já carregadas na sessão — zero placeholder ou sugestão inventada.
    var recentThreads: [AtlasAiThread] {
        Array(session.threads.prefix(12))
    }

    var searchResults: [AtlasAiThread] {
        let q = trimmedQuery.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        guard !q.isEmpty else { return [] }
        return session.threads.filter {
            $0.title.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .contains(q)
        }
    }
}
