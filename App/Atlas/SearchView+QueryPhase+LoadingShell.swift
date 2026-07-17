import SwiftUI
import AtlasCore

// Search loading shell predicate — peel de SearchView+QueryPhase.

extension SearchView {
    var showsLoadingShell: Bool {
        guard session.threads.isEmpty else { return false }
        switch session.phase {
        case .idle, .loading: return true
        default: return false
        }
    }
}
