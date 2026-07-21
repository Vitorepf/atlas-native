import SwiftUI
import AtlasCore

// Search field leading — peel de SearchView+HeaderField.
// Placeholder → SearchView+HeaderFieldPlaceholder.swift
// Input → SearchView+HeaderFieldLeading+FieldInput.swift

extension SearchViewHeader {
    var searchFieldLeading: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            searchFieldInput
            searchClearButton
        }
    }
}
