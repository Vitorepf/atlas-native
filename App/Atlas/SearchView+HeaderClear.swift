import SwiftUI
import AtlasCore

// Clear button — peel de SearchView+HeaderField.
// Spoken → SearchView+HeaderSpoken.swift
// Icon → SearchView+HeaderClearIcon.swift
// A11y → SearchView+HeaderClearA11y.swift
// Action → SearchView+HeaderClear+Action.swift

extension SearchViewHeader {
    @ViewBuilder
    var searchClearButton: some View {
        if !query.isEmpty {
            searchClearA11y(
                Button(action: clearSearchQuery) {
                    searchClearIcon
                }
            )
        }
    }
}
