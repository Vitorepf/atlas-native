import SwiftUI
import AtlasCore

// Loading / offline shells — peel de SearchView+Scroll.
// Loading → SearchView+ScrollShell+Loading.swift · Offline → +ScrollShell+Offline.swift

extension SearchView {
    @ViewBuilder
    var listShellContent: some View {
        if showsLoadingShell {
            searchLoadingShell
        } else if showsNetworkFailure {
            searchOfflineShell
        } else {
            listQueryContent
        }
    }
}
