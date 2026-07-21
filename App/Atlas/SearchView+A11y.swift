import AtlasCore
import SwiftUI

// Cycle 031 fuse → SearchView+A11y.swift

extension SearchView {
    func spokenSearchResultsLabel() -> String {
        if isBrowsingRecent {
            let n = recentThreads.count
            if n == 0 { return "busca, sem recentes neste recorte" }
            return "busca, \(n) recente\(n == 1 ? "" : "s")"
        }
        let n = searchResults.count
        if n == 0 { return "busca, nada com \(trimmedQuery)" }
        return "busca, \(n) resultado\(n == 1 ? "" : "s") para \(trimmedQuery)"
    }
}

extension SearchView {
    func spokenSearchShellLabel() -> String? {
        if showsLoadingShell { return "busca, carregando conversas" }
        if showsNetworkFailure { return "busca, offline" }
        return nil
    }
}

extension SearchView {
    func spokenSearchScreenLabel() -> String {
        spokenSearchShellLabel() ?? spokenSearchResultsLabel()
    }

    static let searchScreenHint = "busca local nas conversas já carregadas na sessão"
}

extension SearchView {
    func searchA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(A11yID.searchScreen)
            .accessibilityLabel(spokenSearchScreenLabel())
            .accessibilityHint(Self.searchScreenHint)
            .onAppear { focused = true }
    }
}
