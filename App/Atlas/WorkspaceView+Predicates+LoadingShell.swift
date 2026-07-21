import SwiftUI
import AtlasCore

// Loading shell predicate — peel de WorkspaceView+Predicates.

extension WorkspaceView {
    var showsLoadingShell: Bool {
        guard session.threads.isEmpty else { return false }
        switch session.phase {
        case .idle, .loading: return true
        default: return false
        }
    }
}
