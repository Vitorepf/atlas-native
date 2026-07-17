import SwiftUI
import AtlasCore

// Search field leading — peel de SearchView+HeaderField.
// Placeholder → SearchView+HeaderFieldPlaceholder.swift

extension SearchViewHeader {
    var searchFieldLeading: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            ZStack(alignment: .leading) {
                searchFieldPlaceholder
                TextField("", text: $query)
                    .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                    .tint(AtlasTheme.accent).focused($focused)
                    .submitLabel(.search)
                    .accessibilityLabel(spokenFieldLabel)
                    .accessibilityHint("filtra só conversas já carregadas na sessão")
                    .accessibilityIdentifier(A11yID.searchField)
            }
            searchClearButton
        }
    }
}
