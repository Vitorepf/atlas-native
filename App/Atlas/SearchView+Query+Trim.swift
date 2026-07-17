import SwiftUI
import AtlasCore

// Query trim + browse gate — peel de SearchView+Query.

extension SearchView {
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    var isBrowsingRecent: Bool { trimmedQuery.isEmpty }
}
