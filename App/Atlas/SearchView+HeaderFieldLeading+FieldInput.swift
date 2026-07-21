import SwiftUI
import AtlasCore

// TextField input — peel de SearchView+HeaderFieldLeading.

extension SearchViewHeader {
    var searchFieldInput: some View {
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
    }
}
