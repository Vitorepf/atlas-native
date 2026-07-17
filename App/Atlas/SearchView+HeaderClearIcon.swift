import SwiftUI
import AtlasCore

// Clear icon — peel de SearchView+HeaderClear.

extension SearchViewHeader {
    var searchClearIcon: some View {
        Image(systemName: "xmark.circle.fill")
            .font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary)
    }
}
