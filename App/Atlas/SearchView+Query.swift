import SwiftUI
import AtlasCore

// Query / results helpers — peel de SearchView.
// Results → SearchView+QueryResults.swift
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
}
