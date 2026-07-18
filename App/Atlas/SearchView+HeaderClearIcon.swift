import SwiftUI
import AtlasCore

// Clear icon — peel de SearchView+HeaderClear.

extension SearchViewHeader {
    var searchClearIcon: some View {
        Image(systemName: "xmark.circle.fill")
            .atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
    }
}
