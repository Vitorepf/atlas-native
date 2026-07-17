import SwiftUI
import AtlasCore

/// Spoken screen label — peel de SearchView (CICLO C residual honesty).
/// Shell → SearchView+A11y+Shell.swift
/// Results → SearchView+A11y+Results.swift

extension SearchView {
    func spokenSearchScreenLabel() -> String {
        spokenSearchShellLabel() ?? spokenSearchResultsLabel()
    }

    static let searchScreenHint = "busca local nas conversas já carregadas na sessão"
}
