import SwiftUI
import AtlasCore

// Clear button — peel de SearchView+HeaderField.
// Spoken → SearchView+HeaderSpoken.swift
// Icon → SearchView+HeaderClearIcon.swift

extension SearchViewHeader {
    @ViewBuilder
    var searchClearButton: some View {
        if !query.isEmpty {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                query = ""
            } label: {
                searchClearIcon
            }
            .buttonStyle(.plain)
            .accessibilityLabel("limpar busca")
            .accessibilityHint("remove o texto e volta aos recentes")
            .accessibilityIdentifier(A11yID.searchClear)
        }
    }
}
