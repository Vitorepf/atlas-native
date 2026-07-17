import SwiftUI
import AtlasCore

/// Spoken screen label — peel de SearchView (CICLO C residual honesty).

extension SearchView {
    func spokenSearchScreenLabel() -> String {
        if showsLoadingShell { return "busca, carregando conversas" }
        if showsNetworkFailure { return "busca, offline" }
        if isBrowsingRecent {
            let n = recentThreads.count
            if n == 0 { return "busca, sem recentes neste recorte" }
            return "busca, \(n) recente\(n == 1 ? "" : "s")"
        }
        let n = searchResults.count
        if n == 0 { return "busca, nada com \(trimmedQuery)" }
        return "busca, \(n) resultado\(n == 1 ? "" : "s") para \(trimmedQuery)"
    }

    static let searchScreenHint = "busca local nas conversas já carregadas na sessão"
}
