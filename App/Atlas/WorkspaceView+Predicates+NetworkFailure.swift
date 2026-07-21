import SwiftUI
import AtlasCore

// Network failure predicate — peel de WorkspaceView+Predicates.

extension WorkspaceView {
    /// Sessão sem threads e load falhou → offline/rede, não "vazio editorial".
    var showsNetworkFailure: Bool {
        guard session.threads.isEmpty else { return false }
        if case .failed = session.phase { return true }
        return false
    }
}
