import SwiftUI
import AtlasCore

// Recent threads — peel de SearchView+Query.

extension SearchView {
    /// Só threads já carregadas na sessão — zero placeholder ou sugestão inventada.
    var recentThreads: [AtlasAiThread] {
        Array(session.threads.prefix(12))
    }
}
