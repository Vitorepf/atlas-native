import SwiftUI
import AtlasCore

/// Search shell spoken — peel de SearchView+A11y.

extension SearchView {
    func spokenSearchShellLabel() -> String? {
        if showsLoadingShell { return "busca, carregando conversas" }
        if showsNetworkFailure { return "busca, offline" }
        return nil
    }
}
