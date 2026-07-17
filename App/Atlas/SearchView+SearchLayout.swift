import SwiftUI
import AtlasCore

// Search layout — peel de SearchView.

extension SearchView {
    var searchLayout: some View {
        VStack(spacing: 0) {
            SearchViewHeader(query: $query, focused: $focused)
            list
        }
    }
}
