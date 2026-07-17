import SwiftUI
import AtlasCore

// Background ZStack — peel de SearchView.

extension SearchView {
    var searchBackgroundShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            searchLayout
        }
    }
}
