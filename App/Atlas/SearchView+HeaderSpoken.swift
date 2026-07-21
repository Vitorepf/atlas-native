import Foundation

// Spoken field label — peel de SearchView+HeaderClear.

extension SearchViewHeader {
    var spokenFieldLabel: String {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "buscar conversas" }
        return "buscar conversas, \(trimmed)"
    }
}
